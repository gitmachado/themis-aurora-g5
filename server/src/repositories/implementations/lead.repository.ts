import { ILeadRepository } from '../interfaces/lead.repository';
import type { Lead } from '@models';
import type { LeadStatus } from '@enums';
import { dbGet, dbAll, dbRun } from '../../config/database';

export class LeadRepository implements ILeadRepository {
  private readonly selectFields = `
    id,
    whatsapp_number as "whatsappNumber",
    name,
    email,
    cpf,
    case_type as "caseType",
    case_description as "caseDescription",
    urgency,
    contact_availability as "contactAvailability",
    status,
    converted_user_id as "convertedUserId",
    assigned_lawyer_id as "assignedLawyerId",
    lawyer_notes as "lawyerNotes",
    discard_reason as "discardReason",
    is_ai_paused as "isAIPaused",
    created_at as "createdAt",
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<Lead | null> {
    return dbGet<Lead>(`SELECT ${this.selectFields} FROM leads WHERE id = $1`, [id]);
  }

  async findByWhatsapp(whatsappNumber: string): Promise<Lead | null> {
    // 1. Busca exata (com ou sem sufixo @s.whatsapp.net)
    const lead = await dbGet<Lead>(`SELECT ${this.selectFields} FROM leads WHERE whatsapp_number = $1`, [whatsappNumber]);
    if (lead) return lead;

    // 2. Busca normalizada (apenas dígitos)
    const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
    if (!normalized) return null;

    // Se o número tem o '9' do Brasil (13 dígitos com 55), tenta também sem o '9' e vice-versa
    let alternative = '';
    if (normalized.startsWith('55') && normalized.length === 13 && normalized[4] === '9') {
      alternative = '55' + normalized.substring(2, 4) + normalized.substring(5); // Remove o 9
    } else if (normalized.startsWith('55') && normalized.length === 12) {
      alternative = '55' + normalized.substring(2, 4) + '9' + normalized.substring(4); // Adiciona o 9
    }

    return dbGet<Lead>(`
      SELECT ${this.selectFields} 
      FROM leads 
      WHERE regexp_replace(whatsapp_number, '\\D', '', 'g') = $1
         OR ( $3 != '' AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $3 )
         OR whatsapp_number LIKE $2
      LIMIT 1
    `, [normalized, `%${normalized}%`, alternative]);
  }

  async findByStatus(status: LeadStatus): Promise<Lead[]> {
    return dbAll<Lead>(
      `SELECT ${this.selectFields}
       FROM leads
       WHERE status = $1
       ORDER BY updated_at DESC`,
      [status]
    );
  }

  async findPending(): Promise<Lead[]> {
    return this.findByStatus('PENDING');
  }

  async findAll(): Promise<Lead[]> {
    return dbAll<Lead>(`SELECT ${this.selectFields} FROM leads ORDER BY created_at DESC`);
  }

  async create(lead: Omit<Lead, 'id' | 'createdAt' | 'updatedAt'>): Promise<Lead> {
    return (await dbGet<Lead>(
      `INSERT INTO leads (whatsapp_number, name, email, cpf, case_type, case_description, urgency, contact_availability, status, converted_user_id, assigned_lawyer_id, lawyer_notes, discard_reason, is_ai_paused)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING ${this.selectFields}`,
      [
        lead.whatsappNumber, lead.name, lead.email, lead.cpf, lead.caseType,
        lead.caseDescription, lead.urgency, lead.contactAvailability,
        lead.status, lead.convertedUserId, lead.assignedLawyerId, lead.lawyerNotes, lead.discardReason,
        lead.isAIPaused ?? false
      ]
    ))!;
  }

  async update(id: string, data: Partial<Lead>): Promise<Lead> {
    const fields = Object.keys(data).filter(key => key !== 'id' && key !== 'createdAt' && key !== 'updatedAt');
    const setClause = fields
      .map((key, index) => {
        const column = key === 'isAIPaused' 
          ? 'is_ai_paused' 
          : key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
        return `${column} = $${index + 2}`;
      })
      .join(', ');

    const values = fields.map(key => data[key as keyof Lead]);

    return (await dbGet<Lead>(
      `UPDATE leads SET ${setClause} WHERE id = $1 RETURNING ${this.selectFields}`,
      [id, ...values]
    ))!;
  }

  async delete(id: string): Promise<void> {
    await dbRun('DELETE FROM leads WHERE id = $1', [id]);
  }
}

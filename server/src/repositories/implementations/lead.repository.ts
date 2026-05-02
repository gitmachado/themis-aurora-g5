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
    lawyer_notes as "lawyerNotes", 
    discard_reason as "discardReason", 
    created_at as "createdAt", 
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<Lead | null> {
    return dbGet<Lead>(`SELECT ${this.selectFields} FROM leads WHERE id = $1`, [id]);
  }

  async findByWhatsapp(whatsappNumber: string): Promise<Lead | null> {
    return dbGet<Lead>(`SELECT ${this.selectFields} FROM leads WHERE whatsapp_number = $1`, [whatsappNumber]);
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

  async create(lead: Omit<Lead, 'id' | 'createdAt' | 'updatedAt'>): Promise<Lead> {
    return (await dbGet<Lead>(
      `INSERT INTO leads (whatsapp_number, name, email, cpf, case_type, case_description, urgency, contact_availability, status, converted_user_id, lawyer_notes, discard_reason)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING ${this.selectFields}`,
      [
        lead.whatsappNumber, lead.name, lead.email, lead.cpf, lead.caseType,
        lead.caseDescription, lead.urgency, lead.contactAvailability,
        lead.status, lead.convertedUserId, lead.lawyerNotes, lead.discardReason
      ]
    ))!;
  }

  async update(id: string, data: Partial<Lead>): Promise<Lead> {
    const fields = Object.keys(data).filter(key => key !== 'id' && key !== 'createdAt' && key !== 'updatedAt');
    const setClause = fields
      .map((key, index) => {
        const column = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
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

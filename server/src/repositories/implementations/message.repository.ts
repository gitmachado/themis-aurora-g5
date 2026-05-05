import { IMessageRepository } from '../interfaces/message.repository';
import type { Message } from '@models';
import { dbGet, dbAll } from '../../config/database';

export class MessageRepository implements IMessageRepository {
  private readonly selectFields = `
    id, 
    lead_id as "leadId", 
    user_id as "userId", 
    whatsapp_number as "whatsappNumber",
    sender, 
    content, 
    whatsapp_message_id as "whatsappMessageId", 
    created_at as "createdAt"
  `;

  async findById(id: string): Promise<Message | null> {
    return dbGet<Message>(`SELECT ${this.selectFields} FROM messages WHERE id = $1`, [id]);
  }

  async findByLeadId(leadId: string): Promise<Message[]> {
    return dbAll<Message>(`SELECT ${this.selectFields} FROM messages WHERE lead_id = $1`, [leadId]);
  }

  async findByUserId(userId: string): Promise<Message[]> {
    return dbAll<Message>(`SELECT ${this.selectFields} FROM messages WHERE user_id = $1`, [userId]);
  }

  async findByWhatsappNumber(whatsappNumber: string): Promise<Message[]> {
    const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
    if (!normalized) return [];

    // Se o número tem o '9' do Brasil (13 dígitos com 55), tenta também sem o '9' e vice-versa
    let alternative = '';
    if (normalized.startsWith('55') && normalized.length === 13 && normalized[4] === '9') {
      alternative = '55' + normalized.substring(2, 4) + normalized.substring(5); // Remove o 9
    } else if (normalized.startsWith('55') && normalized.length === 12) {
      alternative = '55' + normalized.substring(2, 4) + '9' + normalized.substring(4); // Adiciona o 9
    }
    
    // Busca mensagens pelo número exato OU pelo leadId/userId associado a este número
    // Inclui normalização no banco para garantir que pequenas variações de formato não quebrem o histórico
    return dbAll<Message>(`
      SELECT ${this.selectFields} 
      FROM messages 
      WHERE whatsapp_number = $1 
         OR (whatsapp_number IS NOT NULL AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $2)
         OR ( $3 != '' AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $3 )
         OR lead_id IN (
           SELECT id FROM leads 
           WHERE whatsapp_number = $1 
              OR regexp_replace(whatsapp_number, '\\D', '', 'g') = $2
              OR ( $3 != '' AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $3 )
         )
         OR user_id IN (
           SELECT id FROM users 
           WHERE whatsapp_number = $1 
              OR regexp_replace(whatsapp_number, '\\D', '', 'g') = $2
              OR ( $3 != '' AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $3 )
         )
    `, [whatsappNumber, normalized, alternative]);
  }

  async create(message: Omit<Message, 'id' | 'createdAt'>): Promise<Message> {
    return (await dbGet<Message>(
      `INSERT INTO messages (lead_id, user_id, whatsapp_number, sender, content, whatsapp_message_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING ${this.selectFields}`,
      [message.leadId, message.userId, message.whatsappNumber, message.sender, message.content, message.whatsappMessageId]
    ))!;
  }
}

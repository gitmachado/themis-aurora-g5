import { IMessageRepository } from '../interfaces/message.repository';
import type { Message } from '@models';
import { dbGet, dbAll } from '../../config/database';

export class MessageRepository implements IMessageRepository {
  private readonly selectFields = `
    id, 
    lead_id as "leadId", 
    user_id as "userId", 
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

  async create(message: Omit<Message, 'id' | 'createdAt'>): Promise<Message> {
    return (await dbGet<Message>(
      `INSERT INTO messages (lead_id, user_id, sender, content, whatsapp_message_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING ${this.selectFields}`,
      [message.leadId, message.userId, message.sender, message.content, message.whatsappMessageId]
    ))!;
  }
}

import type { Lead } from '@models';
import type { LeadStatus } from '@enums';

export interface ILeadRepository {
  findById(id: string): Promise<Lead | null>;
  findByWhatsapp(whatsappNumber: string): Promise<Lead | null>;
  findByStatus(status: LeadStatus): Promise<Lead[]>;
  findPending(): Promise<Lead[]>;
  findAll(): Promise<Lead[]>;
  create(lead: Omit<Lead, 'id' | 'createdAt' | 'updatedAt'>): Promise<Lead>;
  update(id: string, data: Partial<Lead>): Promise<Lead>;
  delete(id: string): Promise<void>;
}

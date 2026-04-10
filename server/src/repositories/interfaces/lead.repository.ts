import type { Lead } from '@models';
import type { StatusLead } from '@enums';

export interface ILeadRepository {
  findById(id: string): Promise<Lead | null>;
  findByWhatsapp(whatsappNumber: string): Promise<Lead | null>;
  findByStatus(status: StatusLead): Promise<Lead[]>;
  findPending(): Promise<Lead[]>;
  create(lead: Omit<Lead, 'id' | 'createdAt'>): Promise<Lead>;
  update(id: string, data: Partial<Lead>): Promise<Lead>;
  delete(id: string): Promise<void>;
}

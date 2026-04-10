import type { LegalProcess } from '@models';

export interface ILegalProcessRepository {
  findById(id: string): Promise<LegalProcess | null>;
  findByClientId(clientId: string): Promise<LegalProcess[]>;
  findByLawyerId(lawyerId: string): Promise<LegalProcess[]>;
  create(legalProcess: Omit<LegalProcess, 'id' | 'createdAt' | 'updatedAt'>): Promise<LegalProcess>;
  updateStatus(id: string, newStatus: string): Promise<LegalProcess>;
  update(id: string, data: Partial<LegalProcess>): Promise<LegalProcess>;
  delete(id: string): Promise<void>;
}

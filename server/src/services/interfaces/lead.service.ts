import type { Lead, User } from '@models';
import type { CreateLeadDTO, ConvertLeadDTO } from '@dtos';

export interface ILeadService {
  createFromWhatsapp(dto: CreateLeadDTO): Promise<Lead>;
  updateLeadData(id: string, data: Partial<CreateLeadDTO>): Promise<Lead>;
  convertToClient(dto: ConvertLeadDTO): Promise<User>;
  discard(id: string, reason?: string): Promise<Lead>;
  getPending(): Promise<Lead[]>;
  getById(id: string): Promise<Lead | null>;
}

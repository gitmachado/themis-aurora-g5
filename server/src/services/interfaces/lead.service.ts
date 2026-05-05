import type { Lead, User } from '@models';
import type { CreateLeadDTO, ConvertLeadDTO } from '@dtos';
import type { LeadStatus } from '@enums';

export interface ILeadService {
  createFromWhatsapp(dto: CreateLeadDTO): Promise<Lead>;
  updateLeadData(id: string, data: Partial<CreateLeadDTO>): Promise<Lead>;
  convertToClient(dto: ConvertLeadDTO): Promise<User>;
  discard(id: string, reason?: string): Promise<Lead>;
  getPending(): Promise<Lead[]>;
  getAll(): Promise<Lead[]>;
  getByStatus(status: LeadStatus): Promise<Lead[]>;
  getById(id: string): Promise<Lead | null>;
  getByWhatsapp(whatsappNumber: string): Promise<Lead | null>;
  resumeAISupport(whatsappNumber: string): Promise<void>;
  startHandoffSupport(whatsappNumber: string): Promise<void>;
  assignToLawyer(leadId: string, lawyerId: string): Promise<void>;
  releaseFromLawyer(leadId: string): Promise<void>;
  deleteLead(id: string): Promise<void>;
}

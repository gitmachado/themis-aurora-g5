import type { LegalProcess } from '@models';
import type { CreateLegalProcessDTO, UpdateLegalProcessStatusDTO } from '@dtos';

export interface ILegalProcessService {
  create(dto: CreateLegalProcessDTO): Promise<LegalProcess>;
  updateStatus(dto: UpdateLegalProcessStatusDTO): Promise<LegalProcess>;
  addNote(processId: string, note: string, lawyerId: string): Promise<void>;
  requestDocument(processId: string, documentName: string, lawyerId: string): Promise<void>;
  scheduleEvent(processId: string, eventTitle: string, date: Date, lawyerId: string): Promise<void>;
  getByClientId(clientId: string): Promise<LegalProcess[]>;
  getByLawyerId(lawyerId: string): Promise<LegalProcess[]>;
  getById(id: string): Promise<LegalProcess | null>;
}

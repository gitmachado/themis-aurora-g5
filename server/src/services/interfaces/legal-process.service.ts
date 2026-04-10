import type { LegalProcess } from '@models';
import type { CreateLegalProcessDTO, UpdateLegalProcessStatusDTO } from '@dtos';

export interface ILegalProcessService {
  create(dto: CreateLegalProcessDTO): Promise<LegalProcess>;
  updateStatus(dto: UpdateLegalProcessStatusDTO): Promise<LegalProcess>;
  getByClientId(clientId: string): Promise<LegalProcess[]>;
  getById(id: string): Promise<LegalProcess | null>;
}

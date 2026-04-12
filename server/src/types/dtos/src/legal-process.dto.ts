import type { CaseType, LegalProcessStatus } from '@enums';

export interface CreateLegalProcessDTO {
  clientId: string;
  lawyerId?: string;
  title: string;
  description?: string;
  caseType: CaseType;
  processNumber?: string;
}

/** DTO for updating a process status (generates a timeline event) */
export interface UpdateLegalProcessStatusDTO {
  legalProcessId: string;
  newStatus: LegalProcessStatus;
  lawyerNote?: string;
  updatedById: string;
}

import type { CaseType, LegalProcessStatus } from '@enums';

export interface LegalProcess {
  id: string;
  clientId: string;
  lawyerId: string | null;
  title: string;
  description: string | null;
  currentStatus: LegalProcessStatus;
  processNumber: string | null;
  caseType: CaseType;
  lastNote: string | null;
  lastMovementDate: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

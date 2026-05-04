import type {
  CaseType,
  UrgencyLevel,
  LeadStatus,
  ContactAvailability,
} from '@enums';

export interface Lead {
  id: string;
  whatsappNumber: string;
  name: string | null;
  email: string | null;
  cpf: string | null;
  caseType: CaseType | null;
  caseDescription: string | null;
  urgency: UrgencyLevel | null;
  contactAvailability: ContactAvailability | null;
  status: LeadStatus;
  convertedUserId: string | null;
  assignedLawyerId: string | null;
  lawyerNotes: string | null;
  discardReason: string | null;
  isAIPaused: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

import type {
  CaseType,
  UrgencyLevel,
  ContactAvailability,
  LeadStatus,
} from '@enums';

/** DTO for progressive lead creation via WhatsApp bot */
export interface CreateLeadDTO {
  whatsappNumber: string;
  name?: string;
  cpf?: string;
  caseType?: CaseType;
  caseDescription?: string;
  urgency?: UrgencyLevel;
  contactAvailability?: ContactAvailability;
}

export interface UpdateLeadDTO {
  name?: string;
  cpf?: string;
  caseType?: CaseType;
  caseDescription?: string;
  urgency?: UrgencyLevel;
  contactAvailability?: ContactAvailability;
  status?: LeadStatus;
  convertedUserId?: string;
  lawyerNotes?: string;
  discardReason?: string;
}

/** DTO for converting a Lead into a Client (User) */
export interface ConvertLeadDTO {
  leadId: string;
  temporaryPassword?: string;
}

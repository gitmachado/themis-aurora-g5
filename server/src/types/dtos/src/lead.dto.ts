import type {
  TipoCaso,
  NivelUrgencia,
  DisponibilidadeContato,
  StatusLead,
} from '@enums';

/** DTO para criação progressiva de lead via bot WhatsApp */
export interface CreateLeadDTO {
  whatsappNumber: string;
  nome?: string;
  cpf?: string;
  tipoCaso?: TipoCaso;
  descricaoCaso?: string;
  urgencia?: NivelUrgencia;
  disponibilidadeContato?: DisponibilidadeContato;
}

export interface UpdateLeadDTO {
  nome?: string;
  cpf?: string;
  tipoCaso?: TipoCaso;
  descricaoCaso?: string;
  urgencia?: NivelUrgencia;
  disponibilidadeContato?: DisponibilidadeContato;
  status?: StatusLead;
  convertedUserId?: string;
  observacoesAdvogado?: string;
  motivoDescarte?: string;
}

/** DTO para conversão de Lead em Cliente (User) */
export interface ConvertLeadDTO {
  leadId: string;
  senhaTemporaria?: string;
}

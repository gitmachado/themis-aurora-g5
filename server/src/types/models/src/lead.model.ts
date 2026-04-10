import type {
  TipoCaso,
  NivelUrgencia,
  StatusLead,
  DisponibilidadeContato,
} from '@enums';

export interface Lead {
  id: string;
  whatsappNumber: string;
  nome: string | null;
  cpf: string | null;
  tipoCaso: TipoCaso | null;
  descricaoCaso: string | null;
  urgencia: NivelUrgencia | null;
  disponibilidadeContato: DisponibilidadeContato | null;
  status: StatusLead;
  convertedUserId: string | null;
  observacoesAdvogado: string | null;
  motivoDescarte: string | null;
  createdAt: Date;
  updatedAt: Date;
}

import type { TipoNotificacao } from '@enums';

export interface CreateNotificacaoDTO {
  userId: string;
  tipo: TipoNotificacao;
  titulo: string;
  corpo: string;
  dadosExtras?: Record<string, unknown>;
}

import type { TipoEvento } from '@enums';

export interface CreateTimelineEventoDTO {
  processoId: string;
  tipo: TipoEvento;
  conteudo: string;
  metadata?: Record<string, unknown>;
  criadoPorId?: string;
}

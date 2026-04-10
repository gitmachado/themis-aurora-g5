import type { TipoEvento } from '@enums';

export interface TimelineEvento {
  id: string;
  processoId: string;
  tipo: TipoEvento;
  conteudo: string;
  statusAnterior: string | null;
  metadata: Record<string, unknown> | null;
  criadoPorId: string | null;
  createdAt: Date;
  updatedAt: Date;
}

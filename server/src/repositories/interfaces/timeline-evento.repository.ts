import type { TimelineEvento } from '@models';

export interface ITimelineEventoRepository {
  findById(id: string): Promise<TimelineEvento | null>;
  findByProcessoId(processoId: string): Promise<TimelineEvento[]>;
  create(evento: Omit<TimelineEvento, 'id' | 'createdAt'>): Promise<TimelineEvento>;
}

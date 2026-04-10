import type { TimelineEvento } from '@models';
import type { CreateTimelineEventoDTO } from '@dtos';

export interface ITimelineService {
  addEvent(dto: CreateTimelineEventoDTO): Promise<TimelineEvento>;
  getByProcesso(processoId: string): Promise<TimelineEvento[]>;
}

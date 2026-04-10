import type { TimelineEvent } from '@models';
import type { CreateTimelineEventDTO } from '@dtos';

export interface ITimelineService {
  addEvent(dto: CreateTimelineEventDTO): Promise<TimelineEvent>;
  getByLegalProcess(legalProcessId: string): Promise<TimelineEvent[]>;
}

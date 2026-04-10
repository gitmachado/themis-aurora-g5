import type { TimelineEvent } from '@models';

export interface ITimelineEventRepository {
  findById(id: string): Promise<TimelineEvent | null>;
  findByLegalProcessId(legalProcessId: string): Promise<TimelineEvent[]>;
  create(event: Omit<TimelineEvent, 'id' | 'createdAt' | 'updatedAt'>): Promise<TimelineEvent>;
}

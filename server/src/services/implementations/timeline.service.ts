import { ITimelineService } from '../interfaces/timeline.service';
import { ITimelineEventRepository } from '../../repositories/interfaces/timeline-event.repository';
import type { TimelineEvent } from '@models';
import type { CreateTimelineEventDTO } from '@dtos';

export class TimelineService implements ITimelineService {
  constructor(private readonly timelineRepository: ITimelineEventRepository) {}

  async addEvent(dto: CreateTimelineEventDTO): Promise<TimelineEvent> {
    return this.timelineRepository.create({
      legalProcessId: dto.legalProcessId,
      content: dto.content,
      type: dto.type,
      metadata: dto.metadata || null,
      previousStatus: null,
      createdById: dto.createdById || null,
    });
  }

  async getByLegalProcess(legalProcessId: string): Promise<TimelineEvent[]> {
    return this.timelineRepository.findByLegalProcessId(legalProcessId);
  }
}

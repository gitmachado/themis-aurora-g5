import type { TimelineEventType } from '@enums';

export interface CreateTimelineEventDTO {
  legalProcessId: string;
  type: TimelineEventType;
  content: string;
  metadata?: Record<string, unknown>;
  createdById?: string;
}

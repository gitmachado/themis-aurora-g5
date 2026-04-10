import type { TimelineEventType } from '@enums';

export interface TimelineEvent {
  id: string;
  legalProcessId: string;
  type: TimelineEventType;
  content: string;
  previousStatus: string | null;
  metadata: Record<string, unknown> | null;
  createdById: string | null;
  createdAt: Date;
  updatedAt: Date;
}

import { ITimelineEventRepository } from '../interfaces/timeline-event.repository';
import type { TimelineEvent } from '@models';
import { dbGet, dbAll } from '../../config/database';

export class TimelineEventRepository implements ITimelineEventRepository {
  private readonly selectFields = `
    id, 
    legal_process_id as "legalProcessId", 
    type, 
    content, 
    previous_status as "previousStatus", 
    metadata, 
    created_by_id as "createdById", 
    created_at as "createdAt", 
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<TimelineEvent | null> {
    return dbGet<TimelineEvent>(`SELECT ${this.selectFields} FROM timeline_events WHERE id = $1`, [id]);
  }

  async findByLegalProcessId(legalProcessId: string): Promise<TimelineEvent[]> {
    return dbAll<TimelineEvent>(`SELECT ${this.selectFields} FROM timeline_events WHERE legal_process_id = $1`, [legalProcessId]);
  }

  async create(event: Omit<TimelineEvent, 'id' | 'createdAt' | 'updatedAt'>): Promise<TimelineEvent> {
    return (await dbGet<TimelineEvent>(
      `INSERT INTO timeline_events (legal_process_id, type, content, previous_status, metadata, created_by_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING ${this.selectFields}`,
      [event.legalProcessId, event.type, event.content, event.previousStatus, event.metadata, event.createdById]
    ))!;
  }
}

import { dbAll, dbGet, dbRun } from '../../config/database';

export interface ReschedulesSuggestion {
  id: string;
  appointmentId: string;
  lawyerId: string;
  instruction: string;
  suggestedDatetime: Date | null;
  suggestedTitle: string | null;
  suggestedDescription: string | null;
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'SUPERSEDED';
  createdAt: Date;
  updatedAt: Date;
}

export class RescheduleSuggestionRepository {
  private readonly select = `
    id, appointment_id as "appointmentId", lawyer_id as "lawyerId",
    instruction, suggested_datetime as "suggestedDatetime",
    suggested_title as "suggestedTitle", suggested_description as "suggestedDescription",
    status, created_at as "createdAt", updated_at as "updatedAt"
  `;

  async create(data: Omit<ReschedulesSuggestion, 'id' | 'createdAt' | 'updatedAt'>): Promise<ReschedulesSuggestion> {
    const {
      appointmentId,
      lawyerId,
      instruction,
      suggestedDatetime,
      suggestedTitle,
      suggestedDescription,
      status
    } = data;

    const result = await dbGet<ReschedulesSuggestion>(
      `INSERT INTO ai_reschedule_suggestions
       (appointment_id, lawyer_id, instruction, suggested_datetime,
        suggested_title, suggested_description, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING ${this.select}`,
      [appointmentId, lawyerId, instruction, suggestedDatetime, suggestedTitle, suggestedDescription, status]
    );

    if (!result) throw new Error('Failed to create reschedule suggestion');
    return result;
  }

  async findById(id: string): Promise<ReschedulesSuggestion | null> {
    return dbGet<ReschedulesSuggestion>(
      `SELECT ${this.select} FROM ai_reschedule_suggestions WHERE id = $1`,
      [id]
    );
  }

  async findByAppointmentId(appointmentId: string): Promise<ReschedulesSuggestion[]> {
    return dbAll<ReschedulesSuggestion>(
      `SELECT ${this.select} FROM ai_reschedule_suggestions
       WHERE appointment_id = $1
       ORDER BY created_at DESC`,
      [appointmentId]
    );
  }

  async findPendingByAppointmentId(appointmentId: string): Promise<ReschedulesSuggestion[]> {
    return dbAll<ReschedulesSuggestion>(
      `SELECT ${this.select} FROM ai_reschedule_suggestions
       WHERE appointment_id = $1 AND status = 'PENDING'
       ORDER BY created_at DESC`,
      [appointmentId]
    );
  }

  async findByLawyerId(lawyerId: string, status?: string): Promise<ReschedulesSuggestion[]> {
    let query = `SELECT ${this.select} FROM ai_reschedule_suggestions WHERE lawyer_id = $1`;
    const params: any[] = [lawyerId];

    if (status) {
      query += ` AND status = $2`;
      params.push(status);
    }

    query += ` ORDER BY created_at DESC`;
    return dbAll<ReschedulesSuggestion>(query, params);
  }

  async update(id: string, data: Partial<ReschedulesSuggestion>): Promise<ReschedulesSuggestion> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    for (const [key, value] of Object.entries(data)) {
      if (key === 'id' || key === 'createdAt' || key === 'updatedAt') continue;

      const columnName = this.camelToSnake(key);
      updates.push(`${columnName} = $${paramIndex}`);
      values.push(value);
      paramIndex++;
    }

    if (updates.length === 0) {
      const existing = await this.findById(id);
      if (!existing) throw new Error('Reschedule suggestion not found');
      return existing;
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    const query = `
      UPDATE ai_reschedule_suggestions
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING ${this.select}
    `;

    const result = await dbGet<ReschedulesSuggestion>(query, values);
    if (!result) throw new Error('Reschedule suggestion not found');
    return result;
  }

  async markOtherSuggestionsAsSuperseded(appointmentId: string, excludeId: string): Promise<void> {
    await dbRun(
      `UPDATE ai_reschedule_suggestions
       SET status = 'SUPERSEDED', updated_at = NOW()
       WHERE appointment_id = $1 AND id != $2 AND status = 'PENDING'`,
      [appointmentId, excludeId]
    );
  }

  private camelToSnake(str: string): string {
    return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
  }
}

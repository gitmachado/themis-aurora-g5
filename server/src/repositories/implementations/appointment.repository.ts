import { IAppointmentRepository } from '../interfaces/appointment.repository';
import type { Appointment } from '@models';
import { dbAll, dbGet, dbRun } from '../../config/database';

export class AppointmentRepository implements IAppointmentRepository {
  private readonly appointmentSelect = `
    id, lawyer_id as "lawyerId", client_id as "clientId",
    process_id as "processId", title, description, type,
    scheduled_at as "scheduledAt", duration_minutes as "durationMinutes",
    status, reminded, created_by_ai as "createdByAI",
    ai_created_at as "aiCreatedAt", approved_by_lawyer_id as "approvedByLawyerId",
    approved_at as "approvedAt", ai_original_data as "aiOriginalData",
    client_name as "clientName", client_whatsapp_number as "clientWhatsappNumber",
    created_at as "createdAt", updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<Appointment | null> {
    return dbGet<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments WHERE id = $1`,
      [id]
    );
  }

  async findByLawyerId(
    lawyerId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<Appointment[]> {
    let query = `SELECT ${this.appointmentSelect} FROM appointments WHERE lawyer_id = $1`;
    const params: any[] = [lawyerId];

    if (startDate) {
      query += ` AND scheduled_at >= $${params.length + 1}`;
      params.push(startDate);
    }

    if (endDate) {
      query += ` AND scheduled_at <= $${params.length + 1}`;
      params.push(endDate);
    }

    query += ` ORDER BY scheduled_at ASC`;

    return dbAll<Appointment>(query, params);
  }

  async findByClientId(clientId: string): Promise<Appointment[]> {
    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE client_id = $1 AND status = 'SCHEDULED'
       ORDER BY scheduled_at ASC`,
      [clientId]
    );
  }

  async findByProcessId(processId: string): Promise<Appointment[]> {
    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE process_id = $1
       ORDER BY scheduled_at ASC`,
      [processId]
    );
  }

  async findByClientWhatsapp(whatsappNumber: string): Promise<Appointment[]> {
    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE client_whatsapp_number = $1
       ORDER BY scheduled_at DESC`,
      [whatsappNumber]
    );
  }

  async findConflicts(
    lawyerId: string,
    scheduledAt: Date,
    durationMinutes: number
  ): Promise<Appointment[]> {
    const endTime = new Date(scheduledAt.getTime() + durationMinutes * 60000);

    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE lawyer_id = $1
         AND status = 'SCHEDULED'
         AND scheduled_at < $2
         AND (scheduled_at + (INTERVAL '1 minute' * duration_minutes)) > $3
       ORDER BY scheduled_at ASC`,
      [lawyerId, endTime, scheduledAt]
    );
  }

  async findPendingDeadlineReminders(hoursThreshold: number = 24): Promise<Appointment[]> {
    const now = new Date();
    const thresholdTime = new Date(now.getTime() + hoursThreshold * 3600000);

    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE type IN ('DEADLINE', 'HEARING')
         AND status = 'SCHEDULED'
         AND reminded = false
         AND scheduled_at >= $1
         AND scheduled_at <= $2
       ORDER BY scheduled_at ASC`,
      [now, thresholdTime]
    );
  }

  async create(
    appointment: Omit<Appointment, 'id' | 'createdAt' | 'updatedAt'>
  ): Promise<Appointment> {
    const {
      lawyerId,
      clientId,
      processId,
      title,
      description,
      type,
      scheduledAt,
      durationMinutes,
      status,
      reminded,
      createdByAI,
      aiCreatedAt,
      aiOriginalData,
      clientName,
      clientWhatsappNumber
    } = appointment;

    const result = await dbGet<Appointment>(
      `INSERT INTO appointments
       (lawyer_id, client_id, process_id, title, description, type,
        scheduled_at, duration_minutes, status, reminded, created_by_ai,
        ai_created_at, ai_original_data, client_name, client_whatsapp_number)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
       RETURNING ${this.appointmentSelect}`,
      [
        lawyerId,
        clientId,
        processId,
        title,
        description,
        type,
        scheduledAt,
        durationMinutes,
        status,
        reminded,
        createdByAI || false,
        aiCreatedAt || null,
        aiOriginalData || null,
        clientName || null,
        clientWhatsappNumber || null
      ]
    );

    if (!result) throw new Error('Failed to create appointment');
    return result;
  }

  async update(id: string, data: Partial<Appointment>): Promise<Appointment> {
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
      if (!existing) throw new Error('Appointment not found');
      return existing;
    }

    values.push(id);

    updates.push(`updated_at = NOW()`);

    const query = `
      UPDATE appointments
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING ${this.appointmentSelect}
    `;

    const result = await dbGet<Appointment>(query, values);
    if (!result) throw new Error('Appointment not found');
    return result;
  }

  async delete(id: string): Promise<void> {
    await dbRun(`DELETE FROM appointments WHERE id = $1`, [id]);
  }

  async findPendingApprovals(lawyerId: string): Promise<Appointment[]> {
    return dbAll<Appointment>(
      `SELECT ${this.appointmentSelect} FROM appointments
       WHERE lawyer_id = $1 AND status = 'PENDING_APPROVAL'
       ORDER BY created_at DESC`,
      [lawyerId]
    );
  }

  async approveAppointment(
    id: string,
    lawyerId: string,
    edits?: Partial<Appointment>
  ): Promise<Appointment> {
    const appointment = await this.findById(id);
    if (!appointment) throw new Error('Appointment not found');
    if (appointment.lawyerId !== lawyerId) throw new Error('Access denied');
    if (appointment.status !== 'PENDING_APPROVAL') throw new Error('Appointment is not pending approval');

    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (edits) {
      for (const [key, value] of Object.entries(edits)) {
        if (key === 'id' || key === 'createdAt' || key === 'updatedAt' || key === 'status') continue;
        const columnName = this.camelToSnake(key);
        updates.push(`${columnName} = $${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    }

    updates.push(`status = $${paramIndex}`, `approved_by_lawyer_id = $${paramIndex + 1}`, `approved_at = $${paramIndex + 2}`);
    values.push('SCHEDULED', lawyerId, new Date());
    paramIndex += 3;

    values.push(id);
    updates.push(`updated_at = NOW()`);

    const query = `
      UPDATE appointments
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING ${this.appointmentSelect}
    `;

    const result = await dbGet<Appointment>(query, values);
    if (!result) throw new Error('Appointment not found');
    return result;
  }

  async rejectAppointment(id: string, lawyerId: string): Promise<void> {
    const appointment = await this.findById(id);
    if (!appointment) throw new Error('Appointment not found');
    if (appointment.lawyerId !== lawyerId) throw new Error('Access denied');
    if (appointment.status !== 'PENDING_APPROVAL') throw new Error('Appointment is not pending approval');

    await dbRun(
      `DELETE FROM appointments WHERE id = $1`,
      [id]
    );
  }

  async resetToAIVersion(id: string, lawyerId: string): Promise<Appointment> {
    const appointment = await this.findById(id);
    if (!appointment) throw new Error('Appointment not found');
    if (appointment.lawyerId !== lawyerId) throw new Error('Access denied');
    if (appointment.status !== 'PENDING_APPROVAL') throw new Error('Appointment is not pending approval');
    if (!appointment.aiOriginalData) throw new Error('No AI original data found');

    const originalData = appointment.aiOriginalData;
    const result = await dbGet<Appointment>(
      `UPDATE appointments
       SET title = $1, description = $2, scheduled_at = $3, duration_minutes = $4, updated_at = NOW()
       WHERE id = $5
       RETURNING ${this.appointmentSelect}`,
      [
        originalData.title || appointment.title,
        originalData.description || null,
        originalData.scheduledAt || appointment.scheduledAt,
        originalData.durationMinutes || appointment.durationMinutes,
        id
      ]
    );

    if (!result) throw new Error('Failed to reset appointment');
    return result;
  }

  private camelToSnake(str: string): string {
    return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
  }
}

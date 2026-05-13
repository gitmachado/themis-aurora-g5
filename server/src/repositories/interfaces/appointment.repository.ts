import type { Appointment } from '@models';

export interface IAppointmentRepository {
  findById(id: string): Promise<Appointment | null>;
  findByLawyerId(lawyerId: string, startDate?: Date, endDate?: Date): Promise<Appointment[]>;
  findByClientId(clientId: string): Promise<Appointment[]>;
  findByProcessId(processId: string): Promise<Appointment[]>;
  findConflicts(lawyerId: string, scheduledAt: Date, durationMinutes: number): Promise<Appointment[]>;
  findPendingDeadlineReminders(hoursThreshold?: number): Promise<Appointment[]>;
  create(appointment: Omit<Appointment, 'id' | 'createdAt' | 'updatedAt'>): Promise<Appointment>;
  update(id: string, data: Partial<Appointment>): Promise<Appointment>;
  delete(id: string): Promise<void>;
}

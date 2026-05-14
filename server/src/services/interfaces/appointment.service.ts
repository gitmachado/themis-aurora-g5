import type { Appointment } from '@models';
import type { CreateAppointmentDTO, UpdateAppointmentDTO, GetAppointmentSlotsDTO } from '@dtos';

export interface IAppointmentService {
  create(dto: CreateAppointmentDTO, lawyerId: string): Promise<Appointment>;
  update(id: string, dto: UpdateAppointmentDTO, lawyerId: string): Promise<Appointment>;
  delete(id: string, lawyerId: string): Promise<void>;
  getByLawyerId(lawyerId: string, startDate?: Date, endDate?: Date): Promise<Appointment[]>;
  getByClientId(clientId: string): Promise<Appointment[]>;
  getByProcessId(processId: string): Promise<Appointment[]>;
  getById(id: string): Promise<Appointment | null>;
  checkConflicts(lawyerId: string, scheduledAt: Date, durationMinutes: number, excludeId?: string): Promise<Appointment[]>;
  getAvailableSlots(lawyerId: string, date: Date, slotDurationMinutes?: number): Promise<Date[]>;
  processDeadlineReminders(): Promise<void>;
}

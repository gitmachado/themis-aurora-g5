import type { AppointmentType, AppointmentStatus } from '@enums';

export interface CreateAppointmentDTO {
  clientId?: string;
  processId?: string;
  title: string;
  description?: string;
  type: AppointmentType;
  scheduledAt: Date;
  durationMinutes?: number;
}

export interface UpdateAppointmentDTO {
  title?: string;
  description?: string;
  scheduledAt?: Date;
  durationMinutes?: number;
  status?: AppointmentStatus;
}

export interface GetAppointmentSlotsDTO {
  date: Date;
  slotDurationMinutes?: number;
  workStartHour?: number;
  workEndHour?: number;
}

export interface AppointmentResponseDTO {
  id: string;
  lawyerId: string;
  clientId: string | null;
  processId: string | null;
  title: string;
  description: string | null;
  type: AppointmentType;
  scheduledAt: Date;
  durationMinutes: number | null;
  status: AppointmentStatus;
  reminded: boolean;
  createdAt: Date;
  updatedAt: Date;
}

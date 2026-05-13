import type { AppointmentType, AppointmentStatus } from '@enums';

export interface Appointment {
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

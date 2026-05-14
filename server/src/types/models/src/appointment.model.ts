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
  createdByAI: boolean;
  aiCreatedAt: Date | null;
  approvedByLawyerId: string | null;
  approvedAt: Date | null;
  aiOriginalData: Record<string, any> | null;
  clientName: string | null;
  clientWhatsappNumber: string | null;
  createdAt: Date;
  updatedAt: Date;
}

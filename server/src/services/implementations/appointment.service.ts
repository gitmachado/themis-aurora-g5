import { IAppointmentService } from '../interfaces/appointment.service';
import { IAppointmentRepository } from '../../repositories/interfaces/appointment.repository';
import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import type { Appointment } from '@models';
import type { CreateAppointmentDTO, UpdateAppointmentDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';

export class AppointmentService implements IAppointmentService {
  constructor(
    private readonly appointmentRepository: IAppointmentRepository,
    private readonly timelineService: ITimelineService,
    private readonly notificationService: INotificationService
  ) {}

  async create(dto: CreateAppointmentDTO, lawyerId: string): Promise<Appointment> {
    const durationMinutes = dto.durationMinutes || 60;

    const conflicts = await this.appointmentRepository.findConflicts(
      lawyerId,
      dto.scheduledAt,
      durationMinutes
    );

    if (conflicts.length > 0) {
      throw new ConflictError('Horário indisponível: conflito com outro compromisso');
    }

    const appointment = await this.appointmentRepository.create({
      lawyerId,
      clientId: dto.clientId || null,
      processId: dto.processId || null,
      title: dto.title,
      description: dto.description || null,
      type: dto.type,
      scheduledAt: dto.scheduledAt,
      durationMinutes,
      status: 'SCHEDULED',
      reminded: false,
    });

    if (dto.processId) {
      await this.timelineService.addEvent({
        legalProcessId: dto.processId,
        content: `Compromisso agendado: ${dto.title}`,
        type: 'EVENT_SCHEDULED',
      });
    }

    if (dto.clientId) {
      await this.notificationService.send({
        userId: dto.clientId,
        title: 'Reunião agendada',
        body: `Sua reunião foi marcada para ${this.formatDate(dto.scheduledAt)}`,
        type: 'APPOINTMENT_SCHEDULED',
      });
    }

    return appointment;
  }

  async update(id: string, dto: UpdateAppointmentDTO, lawyerId: string): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findById(id);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: compromisso não pertence a você');
    }

    if (dto.scheduledAt && dto.durationMinutes !== undefined) {
      const conflicts = await this.appointmentRepository.findConflicts(
        lawyerId,
        dto.scheduledAt,
        dto.durationMinutes
      );

      const otherConflicts = conflicts.filter(c => c.id !== id);
      if (otherConflicts.length > 0) {
        throw new ConflictError('Novo horário indisponível: conflito com outro compromisso');
      }
    }

    const updated = await this.appointmentRepository.update(id, {
      ...dto,
      updatedAt: new Date(),
    });

    if (appointment.clientId && (dto.scheduledAt || dto.status)) {
      const changeMessage = dto.status
        ? `O status foi alterado para: ${dto.status}`
        : `Foram realizadas alterações no compromisso`;

      await this.notificationService.send({
        userId: appointment.clientId,
        title: 'Compromisso modificado',
        body: changeMessage,
        type: 'APPOINTMENT_CHANGED',
      });
    }

    return updated;
  }

  async delete(id: string, lawyerId: string): Promise<void> {
    const appointment = await this.appointmentRepository.findById(id);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: compromisso não pertence a você');
    }

    if (appointment.clientId) {
      await this.notificationService.send({
        userId: appointment.clientId,
        title: 'Compromisso cancelado',
        body: `O compromisso "${appointment.title}" foi cancelado`,
        type: 'APPOINTMENT_CHANGED',
      });
    }

    await this.appointmentRepository.delete(id);
  }

  async getByLawyerId(lawyerId: string, startDate?: Date, endDate?: Date): Promise<Appointment[]> {
    return this.appointmentRepository.findByLawyerId(lawyerId, startDate, endDate);
  }

  async getByClientId(clientId: string): Promise<Appointment[]> {
    return this.appointmentRepository.findByClientId(clientId);
  }

  async getByProcessId(processId: string): Promise<Appointment[]> {
    return this.appointmentRepository.findByProcessId(processId);
  }

  async getById(id: string): Promise<Appointment | null> {
    return this.appointmentRepository.findById(id);
  }

  async checkConflicts(
    lawyerId: string,
    scheduledAt: Date,
    durationMinutes: number,
    excludeId?: string
  ): Promise<Appointment[]> {
    const conflicts = await this.appointmentRepository.findConflicts(
      lawyerId,
      scheduledAt,
      durationMinutes
    );

    return excludeId ? conflicts.filter(c => c.id !== excludeId) : conflicts;
  }

  async getAvailableSlots(
    lawyerId: string,
    date: Date,
    slotDurationMinutes: number = 60
  ): Promise<Date[]> {
    const startOfDay = new Date(date);
    startOfDay.setHours(9, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(18, 0, 0, 0);

    const appointments = await this.appointmentRepository.findByLawyerId(
      lawyerId,
      startOfDay,
      endOfDay
    );

    const slots: Date[] = [];
    let currentSlot = new Date(startOfDay);

    while (currentSlot < endOfDay) {
      const slotEnd = new Date(currentSlot.getTime() + slotDurationMinutes * 60000);

      const isConflict = appointments.some(app => {
        const appStart = new Date(app.scheduledAt).getTime();
        const appEnd = appStart + (app.durationMinutes || 60) * 60000;
        return currentSlot.getTime() < appEnd && slotEnd.getTime() > appStart;
      });

      if (!isConflict) {
        slots.push(new Date(currentSlot));
      }

      currentSlot = slotEnd;
    }

    return slots;
  }

  async processDeadlineReminders(): Promise<void> {
    const reminders = await this.appointmentRepository.findPendingDeadlineReminders(24);

    for (const reminder of reminders) {
      if (reminder.lawyerId) {
        await this.notificationService.send({
          userId: reminder.lawyerId,
          title: '⚠️ Prazo Crítico Vencendo Amanhã',
          body: `${reminder.title}${reminder.processId ? ' - Processo vinculado' : ''}`,
          type: 'DEADLINE_WARNING',
        });
      }

      await this.appointmentRepository.update(reminder.id, {
        reminded: true,
      });
    }
  }

  private formatDate(date: Date): string {
    return new Intl.DateTimeFormat('pt-BR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  }
}

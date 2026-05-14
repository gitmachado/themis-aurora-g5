import { IAppointmentService } from '../interfaces/appointment.service';
import { IAppointmentRepository } from '../../repositories/interfaces/appointment.repository';
import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import type { Appointment } from '@models';
import type { CreateAppointmentDTO, UpdateAppointmentDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';
import { eventBus } from '../communication/InternalEventBus';

export class AppointmentService implements IAppointmentService {
  constructor(
    private readonly appointmentRepository: IAppointmentRepository,
    private readonly timelineService: ITimelineService,
    private readonly notificationService: INotificationService
  ) {}

  async create(dto: CreateAppointmentDTO, lawyerId: string): Promise<Appointment> {
    const durationMinutes = dto.durationMinutes || 60;
    const scheduledAtDate = typeof dto.scheduledAt === 'string' ? new Date(dto.scheduledAt) : dto.scheduledAt;

    const conflicts = await this.appointmentRepository.findConflicts(
      lawyerId,
      scheduledAtDate,
      durationMinutes
    );

    if (conflicts.length > 0) {
      throw new ConflictError('Horário indisponível: conflito com outro compromisso');
    }

    const status = dto.createdByAI ? 'PENDING_APPROVAL' : (dto.status || 'SCHEDULED');

    const appointment = await this.appointmentRepository.create({
      lawyerId,
      clientId: dto.clientId || null,
      processId: dto.processId || null,
      title: dto.title,
      description: dto.description || null,
      type: dto.type,
      scheduledAt: scheduledAtDate,
      durationMinutes,
      status,
      reminded: false,
      createdByAI: dto.createdByAI,
      aiCreatedAt: dto.createdByAI ? new Date() : undefined,
      aiOriginalData: dto.createdByAI ? {
        title: dto.title,
        description: dto.description,
        scheduledAt: scheduledAtDate,
        durationMinutes,
      } : undefined,
      clientName: dto.clientName || null,
      clientWhatsappNumber: dto.clientWhatsappNumber || null,
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
        body: `Sua reunião foi marcada para ${this.formatDate(scheduledAtDate)}`,
        type: 'APPOINTMENT_SCHEDULED',
      });
    }

    eventBus.emitAppointmentCreated(dto.clientId || lawyerId, appointment);
    if (status === 'PENDING_APPROVAL') {
      eventBus.emitAppointmentCreated(lawyerId, appointment);
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

    const scheduledAtDate = dto.scheduledAt
      ? (typeof dto.scheduledAt === 'string' ? new Date(dto.scheduledAt) : dto.scheduledAt)
      : undefined;

    if (scheduledAtDate && dto.durationMinutes !== undefined) {
      const conflicts = await this.appointmentRepository.findConflicts(
        lawyerId,
        scheduledAtDate,
        dto.durationMinutes
      );

      const otherConflicts = conflicts.filter(c => c.id !== id);
      if (otherConflicts.length > 0) {
        throw new ConflictError('Novo horário indisponível: conflito com outro compromisso');
      }
    }

    const updateData: any = {
      ...dto,
      updatedAt: new Date(),
    };

    // Only include scheduledAt in update if it was provided
    if (scheduledAtDate !== undefined || dto.scheduledAt !== undefined) {
      updateData.scheduledAt = scheduledAtDate ?? dto.scheduledAt;
    } else {
      // Remove scheduledAt from update if not provided
      delete updateData.scheduledAt;
    }

    const updated = await this.appointmentRepository.update(id, updateData);

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

    eventBus.emitAppointmentUpdated(appointment.clientId || lawyerId, updated);
    eventBus.emitAppointmentUpdated(lawyerId, updated);

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

    eventBus.emitAppointmentDeleted(appointment.clientId || lawyerId, id);
    eventBus.emitAppointmentDeleted(lawyerId, id);
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
    slotDurationMinutes: number = 30
  ): Promise<Date[]> {
    // Extrair ano/mês/dia sem conversão de timezone
    const year = date.getUTCFullYear();
    const month = date.getUTCMonth();
    const day = date.getUTCDate();

    // Criar datas no horário de Brasília (UTC-3)
    // 09:00 BRT = 12:00 UTC, 18:00 BRT = 21:00 UTC
    const startOfDay = new Date(Date.UTC(year, month, day, 12, 0, 0)); // 09:00 BRT
    const endOfDay = new Date(Date.UTC(year, month, day, 21, 0, 0));   // 18:00 BRT

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
        eventBus.emitDeadlineReminder(reminder.lawyerId, reminder);
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

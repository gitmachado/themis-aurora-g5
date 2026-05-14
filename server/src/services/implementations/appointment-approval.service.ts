import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import { RescheduleSuggestionRepository, ReschedulesSuggestion } from '../../repositories/implementations/reschedule-suggestion.repository';
import type { Appointment } from '@models';
import type { UpdateAppointmentDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';

export class AppointmentApprovalService {
  constructor(
    private readonly appointmentRepository: AppointmentRepository,
    private readonly rescheduleSuggestionRepository: RescheduleSuggestionRepository,
    private readonly timelineService: ITimelineService,
    private readonly notificationService: INotificationService
  ) {}

  async getPendingApprovals(lawyerId: string): Promise<Appointment[]> {
    return this.appointmentRepository.findPendingApprovals(lawyerId);
  }

  async approveAppointment(
    appointmentId: string,
    lawyerId: string,
    edits?: UpdateAppointmentDTO
  ): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode aprovar um compromisso que não é seu');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError('Este compromisso não está pendente de aprovação');
    }

    const updated = await this.appointmentRepository.approveAppointment(
      appointmentId,
      lawyerId,
      edits as any
    );

    // Notify client about approval
    if (updated.clientId) {
      await this.notificationService.send({
        userId: updated.clientId,
        title: 'Reunião confirmada',
        body: `Sua reunião foi confirmada para ${this.formatDate(updated.scheduledAt)}`,
        type: 'APPOINTMENT_SCHEDULED',
      });
    }

    // Add timeline event if linked to process
    if (updated.processId) {
      await this.timelineService.addEvent({
        legalProcessId: updated.processId,
        content: `Compromisso aprovado e confirmado: ${updated.title}`,
        type: 'EVENT_SCHEDULED',
      });
    }

    return updated;
  }

  async rejectAppointment(appointmentId: string, lawyerId: string): Promise<void> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode rejeitar um compromisso que não é seu');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError('Este compromisso não está pendente de aprovação');
    }

    await this.appointmentRepository.rejectAppointment(appointmentId, lawyerId);

    // Notify client about rejection
    if (appointment.clientId) {
      await this.notificationService.send({
        userId: appointment.clientId,
        title: 'Reunião não confirmada',
        body: 'Sua solicitação de reunião foi revista. Por favor, contate-nos para agendar.',
        type: 'APPOINTMENT_CHANGED',
      });
    }
  }

  async resetToAIVersion(appointmentId: string, lawyerId: string): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode resetar um compromisso que não é seu');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError('Este compromisso não está pendente de aprovação');
    }

    return this.appointmentRepository.resetToAIVersion(appointmentId, lawyerId);
  }

  async requestReschedule(
    appointmentId: string,
    lawyerId: string,
    instruction: string
  ): Promise<ReschedulesSuggestion> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode reagendar um compromisso que não é seu');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError('Este compromisso não está pendente de aprovação');
    }

    return this.rescheduleSuggestionRepository.create({
      appointmentId,
      lawyerId,
      instruction,
      suggestedDatetime: null,
      suggestedTitle: null,
      suggestedDescription: null,
      status: 'PENDING'
    });
  }

  async getRescheduleSuggestions(appointmentId: string, lawyerId: string): Promise<ReschedulesSuggestion[]> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode visualizar sugestões de um compromisso que não é seu');
    }

    return this.rescheduleSuggestionRepository.findPendingByAppointmentId(appointmentId);
  }

  async acceptReschedule(
    suggestionId: string,
    appointmentId: string,
    lawyerId: string
  ): Promise<Appointment> {
    const suggestion = await this.rescheduleSuggestionRepository.findById(suggestionId);
    if (!suggestion) {
      throw new NotFoundError('Sugestão de reagendamento não encontrada');
    }

    if (suggestion.status !== 'PENDING') {
      throw new ConflictError('Esta sugestão não está mais disponível');
    }

    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode aceitar sugestão de um compromisso que não é seu');
    }

    // Update appointment with suggested values
    const updated = await this.appointmentRepository.update(appointmentId, {
      title: suggestion.suggestedTitle || appointment.title,
      description: suggestion.suggestedDescription || appointment.description,
      scheduledAt: suggestion.suggestedDatetime || appointment.scheduledAt,
    } as any);

    // Mark this suggestion as accepted and others as superseded
    await this.rescheduleSuggestionRepository.update(suggestionId, {
      status: 'ACCEPTED'
    });

    await this.rescheduleSuggestionRepository.markOtherSuggestionsAsSuperseded(appointmentId, suggestionId);

    return updated;
  }

  async rejectReschedule(suggestionId: string, lawyerId: string): Promise<void> {
    const suggestion = await this.rescheduleSuggestionRepository.findById(suggestionId);
    if (!suggestion) {
      throw new NotFoundError('Sugestão de reagendamento não encontrada');
    }

    if (suggestion.lawyerId !== lawyerId) {
      throw new ConflictError('Você não pode rejeitar sugestão de outro advogado');
    }

    if (suggestion.status !== 'PENDING') {
      throw new ConflictError('Esta sugestão não está mais disponível');
    }

    await this.rescheduleSuggestionRepository.update(suggestionId, {
      status: 'REJECTED'
    });
  }

  private formatDate(date: Date): string {
    const d = new Date(date);
    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const year = d.getFullYear();
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');
    return `${day}/${month}/${year} às ${hours}:${minutes}`;
  }
}

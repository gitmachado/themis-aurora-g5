import { ITimelineService } from '../interfaces/timeline.service';
import { INotificationService } from '../interfaces/notification.service';
import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import { RescheduleSuggestionRepository, ReschedulesSuggestion } from '../../repositories/implementations/reschedule-suggestion.repository';
import { AppointmentValidators } from './appointment-validators';
import { AppointmentAuditService } from './appointment-audit.service';
import { AppointmentWhatsAppNotifier } from './appointment-whatsapp-notifier';
import type { Appointment } from '@models';
import type { UpdateAppointmentDTO } from '@dtos';
import { NotFoundError, ConflictError } from './errors';
import { eventBus } from '../communication/InternalEventBus';

export class AppointmentApprovalService {
  private readonly auditService: AppointmentAuditService;
  private readonly whatsappNotifier: AppointmentWhatsAppNotifier;

  constructor(
    private readonly appointmentRepository: AppointmentRepository,
    private readonly rescheduleSuggestionRepository: RescheduleSuggestionRepository,
    private readonly timelineService: ITimelineService,
    private readonly notificationService: INotificationService
  ) {
    this.auditService = new AppointmentAuditService(appointmentRepository);
    this.whatsappNotifier = new AppointmentWhatsAppNotifier();
  }

  async getPendingApprovals(lawyerId: string): Promise<Appointment[]> {
    return this.appointmentRepository.findPendingApprovals(lawyerId);
  }

  async approveAppointment(
    appointmentId: string,
    lawyerId: string,
    edits?: UpdateAppointmentDTO
  ): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    AppointmentValidators.validateApprovalPermission(appointment, lawyerId);

    const updated = await this.appointmentRepository.approveAppointment(
      appointmentId,
      lawyerId,
      edits as any
    );

    // Notify client about approval
    if (updated.clientId) {
      const hadEdits = !!edits;
      const editDetails = hadEdits ? ' O advogado fez alguns ajustes no horário e detalhes da reunião.' : '';

      // Enviar notificação push
      await this.notificationService.send({
        userId: updated.clientId,
        title: 'Reunião confirmada ✅',
        body: `Sua reunião foi confirmada para ${this.formatDate(updated.scheduledAt)}.${editDetails}`,
        type: 'APPOINTMENT_SCHEDULED',
        metadata: {
          appointmentId: updated.id,
          scheduledAt: updated.scheduledAt.toISOString(),
          title: updated.title,
          clientWhatsapp: updated.clientWhatsappNumber,
          hadEdits,
          whatsappTemplate: 'APPOINTMENT_APPROVED',
        },
      });

      // Enviar mensagem via WhatsApp (apenas para agendamentos criados pela IA)
      if (updated.createdByAI && updated.clientWhatsappNumber && updated.clientName) {
        try {
          await this.whatsappNotifier.notifyAppointmentApproved({
            clientWhatsapp: updated.clientWhatsappNumber,
            clientName: updated.clientName,
            appointmentTitle: updated.title,
            scheduledAt: updated.scheduledAt,
            hadEdits,
          });
        } catch (err) {
          console.error('[AppointmentApprovalService] Erro ao enviar WhatsApp:', err);
        }
      }
    }

    // Add timeline event if linked to process
    if (updated.processId) {
      await this.timelineService.addEvent({
        legalProcessId: updated.processId,
        content: `Compromisso aprovado e confirmado: ${updated.title}`,
        type: 'EVENT_SCHEDULED',
      });
    }

    // Log audit
    this.auditService.logApproval(appointmentId, lawyerId, !!edits);

    // Emit socket events
    eventBus.emitAppointmentApproved(lawyerId, updated);

    return updated;
  }

  async rejectAppointment(appointmentId: string, lawyerId: string): Promise<void> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    AppointmentValidators.validateRejectionPermission(appointment, lawyerId);

    await this.appointmentRepository.rejectAppointment(appointmentId, lawyerId);

    // Notify client about rejection
    if (appointment.clientId) {
      await this.notificationService.send({
        userId: appointment.clientId,
        title: 'Reunião não confirmada ⚠️',
        body: 'Sua solicitação de reunião foi revista pelo advogado e não foi confirmada. Entre em contato conosco para reagendar para um melhor horário.',
        type: 'APPOINTMENT_CHANGED',
        metadata: {
          appointmentId: appointment.id,
          action: 'REJECTION',
          whatsappTemplate: 'APPOINTMENT_REJECTED',
        },
      });
      this.auditService.logNotificationSent(appointment.clientId, 'APPOINTMENT_CHANGED', 'APPOINTMENT_REJECTED');

      // Enviar mensagem de rejeição via WhatsApp (apenas para agendamentos criados pela IA)
      if (appointment.createdByAI && appointment.clientWhatsappNumber && appointment.clientName) {
        try {
          await this.whatsappNotifier.notifyAppointmentRejected({
            clientWhatsapp: appointment.clientWhatsappNumber,
            clientName: appointment.clientName,
            appointmentTitle: appointment.title,
          });
        } catch (err) {
          console.error('[AppointmentApprovalService] Erro ao enviar WhatsApp de rejeição:', err);
        }
      }
    }

    // Log audit
    this.auditService.logRejection(appointmentId, lawyerId);

    // Emit socket events
    eventBus.emitAppointmentRejected(lawyerId, appointmentId);
  }

  async resetToAIVersion(appointmentId: string, lawyerId: string): Promise<Appointment> {
    const appointment = await this.appointmentRepository.findById(appointmentId);
    AppointmentValidators.validateResetPermission(appointment, lawyerId);

    return this.appointmentRepository.resetToAIVersion(appointmentId, lawyerId);
  }

  async requestReschedule(
    appointmentId: string,
    lawyerId: string,
    instruction: string
  ): Promise<ReschedulesSuggestion> {
    AppointmentValidators.validateRescheduleInstruction(instruction);

    const appointment = await this.appointmentRepository.findById(appointmentId);
    AppointmentValidators.validateReschedulePermission(appointment, lawyerId);

    const suggestion = await this.rescheduleSuggestionRepository.create({
      appointmentId,
      lawyerId,
      instruction,
      suggestedDatetime: null,
      suggestedTitle: null,
      suggestedDescription: null,
      status: 'PENDING'
    });

    // Log audit
    this.auditService.logRescheduleRequest(appointmentId, lawyerId, instruction);

    return suggestion;
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

    // Emit socket events
    eventBus.emitRescheduleAccepted(lawyerId, updated);

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

    // Emit socket events
    eventBus.emitRescheduleRejected(lawyerId, suggestionId);
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

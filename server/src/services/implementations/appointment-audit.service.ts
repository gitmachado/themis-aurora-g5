import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import type { Appointment } from '@models';

/**
 * Serviço de auditoria e logging para o fluxo de aprovação
 * Registra todas as ações importantes para observabilidade
 */
export class AppointmentAuditService {
  private readonly appointmentRepository: AppointmentRepository;

  constructor(appointmentRepository?: AppointmentRepository) {
    this.appointmentRepository = appointmentRepository || new AppointmentRepository();
  }

  /**
   * Log quando IA cria um agendamento
   */
  logAIScheduleCreation(appointment: Appointment, instruction?: string): void {
    console.log(
      `[AUDIT] ✨ AI_SCHEDULE_CREATED | ` +
      `apt_id=${appointment.id} | ` +
      `lawyer_id=${appointment.lawyerId} | ` +
      `client_id=${appointment.clientId} | ` +
      `title="${appointment.title}" | ` +
      `timestamp=${new Date().toISOString()}`
    );

    if (instruction) {
      console.log(`[AUDIT] 📝 AI_INSTRUCTION | apt_id=${appointment.id} | "${instruction}"`);
    }
  }

  /**
   * Log quando advogado aprova
   */
  logApproval(appointmentId: string, lawyerId: string, edits?: boolean): void {
    console.log(
      `[AUDIT] ✅ APPOINTMENT_APPROVED | ` +
      `apt_id=${appointmentId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `edits=${!!edits} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log quando advogado rejeita
   */
  logRejection(appointmentId: string, lawyerId: string): void {
    console.log(
      `[AUDIT] ❌ APPOINTMENT_REJECTED | ` +
      `apt_id=${appointmentId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log quando advogado reseta para versão original
   */
  logReset(appointmentId: string, lawyerId: string): void {
    console.log(
      `[AUDIT] 🔄 APPOINTMENT_RESET_TO_AI | ` +
      `apt_id=${appointmentId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log quando advogado solicita reagendamento
   */
  logRescheduleRequest(appointmentId: string, lawyerId: string, instruction: string): void {
    console.log(
      `[AUDIT] 🔄 RESCHEDULE_REQUESTED | ` +
      `apt_id=${appointmentId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `instruction="${instruction.substring(0, 50)}..." | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log quando sugestão é aceita
   */
  logSuggestionAccepted(appointmentId: string, suggestionId: string, lawyerId: string): void {
    console.log(
      `[AUDIT] ✅ SUGGESTION_ACCEPTED | ` +
      `apt_id=${appointmentId} | ` +
      `sug_id=${suggestionId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log quando sugestão é rejeitada
   */
  logSuggestionRejected(suggestionId: string, lawyerId: string): void {
    console.log(
      `[AUDIT] ❌ SUGGESTION_REJECTED | ` +
      `sug_id=${suggestionId} | ` +
      `lawyer_id=${lawyerId} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log de notificação enviada
   */
  logNotificationSent(userId: string, type: string, templateType?: string): void {
    console.log(
      `[AUDIT] 💬 NOTIFICATION_SENT | ` +
      `user_id=${userId} | ` +
      `type=${type} | ` +
      `template=${templateType} | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Log de erro no processamento da IA
   */
  logAIProcessingError(appointmentId: string, error: string): void {
    console.error(
      `[AUDIT] ⚠️ AI_PROCESSING_ERROR | ` +
      `apt_id=${appointmentId} | ` +
      `error="${error}" | ` +
      `timestamp=${new Date().toISOString()}`
    );
  }

  /**
   * Métricas agregadas (para observabilidade)
   */
  async getApprovalMetrics(lawyerId: string): Promise<{
    totalApprovals: number;
    totalRejections: number;
    totalRescheduleRequests: number;
    approvalRate: number;
    averageTimeToApproval: number;
  }> {
    // TODO: Implementar queries para puxar dados

    return {
      totalApprovals: 0,
      totalRejections: 0,
      totalRescheduleRequests: 0,
      approvalRate: 0,
      averageTimeToApproval: 0,
    };
  }
}

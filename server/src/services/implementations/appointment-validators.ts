import { ConflictError, NotFoundError, ValidationError } from './errors';
import type { Appointment } from '@models';

/**
 * Validadores para o fluxo de aprovação de agendamentos
 */
export class AppointmentValidators {
  /**
   * Valida se um agendamento pode ser aprovado
   */
  static validateApprovalPermission(appointment: Appointment | null, lawyerId: string): void {
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: este compromisso não pertence a você');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError(
        `Compromisso não pode ser aprovado. Status atual: ${appointment.status}. ` +
        'Apenas compromissos pendentes de aprovação podem ser aprovados.'
      );
    }

    if (!appointment.createdByAI) {
      throw new ConflictError('Apenas compromissos criados pela IA podem ser aprovados através deste fluxo');
    }
  }

  /**
   * Valida se um agendamento pode ser rejeitado
   */
  static validateRejectionPermission(appointment: Appointment | null, lawyerId: string): void {
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: este compromisso não pertence a você');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError(
        `Compromisso não pode ser rejeitado. Status atual: ${appointment.status}. ` +
        'Apenas compromissos pendentes de aprovação podem ser rejeitados.'
      );
    }
  }

  /**
   * Valida se um agendamento pode ser resetado
   */
  static validateResetPermission(appointment: Appointment | null, lawyerId: string): void {
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: este compromisso não pertence a você');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError(
        `Compromisso não pode ser resetado. Status atual: ${appointment.status}. ` +
        'Apenas compromissos pendentes de aprovação podem ser resetados.'
      );
    }

    if (!appointment.createdByAI || !appointment.aiOriginalData) {
      throw new ConflictError('Compromisso não tem dados originais da IA para restaurar');
    }
  }

  /**
   * Valida se um agendamento pode ter reagendamento solicitado
   */
  static validateReschedulePermission(appointment: Appointment | null, lawyerId: string): void {
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: este compromisso não pertence a você');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError(
        `Reagendamento não pode ser solicitado. Status atual: ${appointment.status}. ` +
        'Apenas compromissos pendentes de aprovação podem ter reagendamento solicitado.'
      );
    }
  }

  /**
   * Valida instrução de reagendamento
   */
  static validateRescheduleInstruction(instruction: string): void {
    if (!instruction || instruction.trim().length === 0) {
      throw new ValidationError('Instrução de reagendamento não pode estar vazia');
    }

    if (instruction.length > 500) {
      throw new ValidationError('Instrução de reagendamento não pode ter mais de 500 caracteres');
    }
  }

  /**
   * Valida permissão para aceitar sugestão de reagendamento
   */
  static validateAcceptSuggestionPermission(
    appointment: Appointment | null,
    lawyerId: string,
    suggestionStatus: string
  ): void {
    if (!appointment) {
      throw new NotFoundError('Compromisso não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new ConflictError('Acesso negado: este compromisso não pertence a você');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new ConflictError('Compromisso não está mais pendente de aprovação');
    }

    if (suggestionStatus !== 'PENDING') {
      throw new ConflictError('Esta sugestão não está mais disponível para aceitar');
    }
  }
}

// Erro de validação customizado
export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

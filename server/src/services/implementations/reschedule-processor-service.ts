import { RescheduleSuggestionRepository } from '../../repositories/implementations/reschedule-suggestion.repository';
import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import { RescheduleSuggestionsProcessor } from '../../jobs/reschedule-suggestions-processor';

/**
 * Serviço que orquestra o processamento de sugestões de reagendamento
 * Recebe requisição de reagendamento e dispara processamento
 */
export class RescheduleProcessorService {
  private readonly suggestionsRepo: RescheduleSuggestionRepository;
  private readonly appointmentRepo: AppointmentRepository;
  private readonly processor: RescheduleSuggestionsProcessor;

  constructor() {
    this.suggestionsRepo = new RescheduleSuggestionRepository();
    this.appointmentRepo = new AppointmentRepository();
    this.processor = new RescheduleSuggestionsProcessor(this.suggestionsRepo, this.appointmentRepo);
  }

  /**
   * Inicia processamento de reagendamento
   * Chamado quando advogado clica "Pedir IA Reagendar"
   */
  async initiateReschedule(
    appointmentId: string,
    lawyerId: string,
    instruction: string
  ): Promise<{ suggestionId: string; status: string }> {
    // Validar appointment
    const appointment = await this.appointmentRepo.findById(appointmentId);
    if (!appointment) {
      throw new Error('Appointment não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new Error('Você não pode reagendar um appointment que não é seu');
    }

    if (appointment.status !== 'PENDING_APPROVAL') {
      throw new Error('Apenas appointments em PENDING_APPROVAL podem ser reagendados');
    }

    // Criar nova sugestão (status: PENDING)
    const suggestion = await this.suggestionsRepo.create({
      appointmentId,
      lawyerId,
      instruction,
      suggestedDatetime: null,
      suggestedTitle: null,
      suggestedDescription: null,
      status: 'PENDING',
    });

    console.log(`[Reschedule] Sugestão criada: ${suggestion.id}`);

    // Disparar processamento assincronamente
    // Isso pode ser:
    // 1. Background job immediatamente
    // 2. Fila de processamento
    // 3. Ou apenas confiar que um cron job vai pegar depois
    this.processSuggestionAsync(suggestion.id);

    return {
      suggestionId: suggestion.id,
      status: 'PROCESSING',
    };
  }

  /**
   * Processa sugestão de forma assincronizada
   * Não bloqueia a requisição HTTP
   */
  private processSuggestionAsync(suggestionId: string): void {
    // Fire and forget
    this.processor
      .processRescheduleSuggestion(suggestionId)
      .catch((err) => {
        console.error(`[Reschedule] Erro ao processar ${suggestionId}:`, err);
      });
  }

  /**
   * Retorna sugestões pendentes e aceitas para um appointment
   * Chamado via polling pelo frontend
   */
  async getSuggestionsForAppointment(
    appointmentId: string,
    lawyerId: string
  ): Promise<Array<{
    id: string;
    suggestedDatetime: Date | null;
    suggestedTitle: string | null;
    suggestedDescription: string | null;
    status: string;
  }>> {
    // Verificar ownership
    const appointment = await this.appointmentRepo.findById(appointmentId);
    if (!appointment) {
      throw new Error('Appointment não encontrado');
    }

    if (appointment.lawyerId !== lawyerId) {
      throw new Error('Acesso negado');
    }

    // Retornar sugestões (PENDING significa "aguardando processamento", ACCEPTED meio que não existe mais)
    const suggestions = await this.suggestionsRepo.findByAppointmentId(appointmentId);

    return suggestions
      .filter((s) => s.status === 'PENDING' || s.status === 'ACCEPTED')
      .map((s) => ({
        id: s.id,
        suggestedDatetime: s.suggestedDatetime,
        suggestedTitle: s.suggestedTitle,
        suggestedDescription: s.suggestedDescription,
        status: s.status,
      }));
  }
}

import { RescheduleSuggestionRepository, ReschedulesSuggestion } from '../repositories/implementations/reschedule-suggestion.repository';
import { AppointmentRepository } from '../repositories/implementations/appointment.repository';
import { ChatOpenAI } from '@langchain/openai';
import type { Appointment } from '@models';

/**
 * Background job que processa sugestões de reagendamento da IA
 * Monitora appointments com status PENDING_APPROVAL + instrução de reagendamento
 * Gera sugestões de novos horários usando Claude/OpenAI
 */
export class RescheduleSuggestionsProcessor {
  private readonly suggestionsRepo: RescheduleSuggestionRepository;
  private readonly appointmentRepo: AppointmentRepository;
  private readonly aiModel: ChatOpenAI | null;

  constructor(
    suggestionsRepo?: RescheduleSuggestionRepository,
    appointmentRepo?: AppointmentRepository
  ) {
    this.suggestionsRepo = suggestionsRepo || new RescheduleSuggestionRepository();
    this.appointmentRepo = appointmentRepo || new AppointmentRepository();

    try {
      this.aiModel = new ChatOpenAI({
        modelName: 'gpt-4o-mini',
        temperature: 0.3,
      });
    } catch (error) {
      console.warn('[RescheduleSuggestionsProcessor] ⚠️ OpenAI API key not configured. Suggestion generation will be disabled.');
      this.aiModel = null;
    }
  }

  /**
   * Processa uma sugestão de reagendamento
   * Chamado pelo job scheduler periodicamente ou via endpoint
   */
  async processRescheduleSuggestion(suggestionId: string): Promise<void> {
    try {
      const suggestion = await this.suggestionsRepo.findById(suggestionId);
      if (!suggestion) {
        console.warn(`[Reschedule] Sugestão ${suggestionId} não encontrada`);
        return;
      }

      if (suggestion.status !== 'PENDING') {
        console.log(`[Reschedule] Sugestão ${suggestionId} não está PENDING (status: ${suggestion.status})`);
        return;
      }

      const appointment = await this.appointmentRepo.findById(suggestion.appointmentId);
      if (!appointment) {
        console.error(`[Reschedule] Appointment ${suggestion.appointmentId} não encontrado`);
        return;
      }

      console.log(`[Reschedule] Processando sugestão ${suggestionId} para ${appointment.title}`);

      // Gera sugestões de horários alternativos
      const alternatives = await this.generateAlternativeSlots(appointment, suggestion);

      // Usa a primeira sugestão gerada
      if (alternatives.length > 0) {
        const best = alternatives[0];

        await this.suggestionsRepo.update(suggestionId, {
          suggestedDatetime: best.datetime,
          suggestedTitle: best.title,
          suggestedDescription: best.description,
        });

        console.log(`[Reschedule] Sugestão ${suggestionId} atualizada com novo horário: ${best.datetime}`);
      } else {
        console.warn(`[Reschedule] Nenhum horário alternativo encontrado para sugestão ${suggestionId}`);
      }
    } catch (error) {
      console.error(`[Reschedule] Erro ao processar sugestão ${suggestionId}:`, error);
      throw error;
    }
  }

  /**
   * Processa TODAS as sugestões pendentes (chamado pelo cron job)
   */
  async processAllPending(): Promise<void> {
    try {
      console.log('[Reschedule] Processando todas as sugestões pendentes...');

      // Buscar todas as sugestões pendentes
      const lawyerIds = await this.getAllLawyerIdsWithPendingReschedules();

      let processedCount = 0;
      for (const lawyerId of lawyerIds) {
        const suggestions = await this.suggestionsRepo.findByLawyerId(lawyerId, 'PENDING');
        for (const suggestion of suggestions) {
          await this.processRescheduleSuggestion(suggestion.id);
          processedCount++;
        }
      }

      console.log(`[Reschedule] Processadas ${processedCount} sugestões pendentes`);
    } catch (error) {
      console.error('[Reschedule] Erro ao processar sugestões pendentes:', error);
    }
  }

  /**
   * Gera sugestões de horários alternativos usando IA
   * Baseado na instrução do advogado (ex: "não segunda, a partir de terça")
   */
  private async generateAlternativeSlots(
    appointment: Appointment,
    suggestion: ReschedulesSuggestion
  ): Promise<Array<{ datetime: Date; title: string; description: string }>> {
    try {
      if (!this.aiModel) {
        console.warn('[Reschedule] OpenAI model not initialized. Cannot generate suggestions.');
        return [];
      }

      const prompt = `
Você é um assistente de agendamento de um escritório de advocacia.

Contexto:
- Compromisso original: "${appointment.title}" em ${new Date(appointment.scheduledAt).toLocaleDateString('pt-BR')} às ${new Date(appointment.scheduledAt).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
- Duração: ${appointment.durationMinutes} minutos
- Instrução do advogado: "${suggestion.instruction}"

Sua tarefa é gerar 3 sugestões de horários alternativos que:
1. Respeitam a instrução do advogado
2. São em horários comerciais (09:00-18:00)
3. São dias úteis (seg-sex)
4. São nos próximos 7 a 14 dias

Retorne exatamente neste formato JSON (sem markdown):
[
  {
    "datetime": "YYYY-MM-DDTHH:mm:00Z",
    "title": "Título atualizado",
    "description": "Descrição breve"
  }
]

Notas importantes:
- Use horários que facam sentido (como o original): ${new Date(appointment.scheduledAt).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
- Mantenha a mesma duração
- Seja criativo mas realista
`;

      const response = await this.aiModel.invoke(prompt);
      const content = String(response.content);

      // Parse JSON response
      const jsonMatch = content.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        console.warn('[Reschedule] Resposta da IA não contém JSON válido');
        return [];
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return parsed.map((item: any) => ({
        datetime: new Date(item.datetime),
        title: item.title || appointment.title,
        description: item.description || appointment.description || '',
      }));
    } catch (error) {
      console.error('[Reschedule] Erro ao gerar sugestões de IA:', error);
      return [];
    }
  }

  /**
   * Helper: obtém todos os lawyer IDs com sugestões pendentes
   */
  private async getAllLawyerIdsWithPendingReschedules(): Promise<string[]> {
    // TODO: Implementar query mais eficiente
    // Por enquanto, retorna array vazio (isso seria feito via query SQL direta)
    return [];
  }
}

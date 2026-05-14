import cron from 'node-cron';
import { RescheduleSuggestionsProcessor } from './reschedule-suggestions-processor';

let rescheduleProcessor: RescheduleSuggestionsProcessor | null = null;
let cronJobHandle: cron.ScheduledTask | null = null;

/**
 * Inicializa o scheduler de jobs
 * Deve ser chamado uma vez na inicialização da aplicação
 */
export function initializeScheduler(): void {
  rescheduleProcessor = new RescheduleSuggestionsProcessor();

  // Processa sugestões pendentes a cada 2 minutos
  cronJobHandle = cron.schedule('*/2 * * * *', async () => {
    try {
      console.log('[Scheduler] Iniciando processamento de sugestões pendentes...');
      await rescheduleProcessor!.processAllPending();
    } catch (error) {
      console.error('[Scheduler] Erro ao processar sugestões:', error);
    }
  });

  console.log('[Scheduler] ✅ Scheduler inicializado (processamento a cada 2 minutos)');
}

/**
 * Para o scheduler (útil para testes e shutdown)
 */
export function stopScheduler(): void {
  if (cronJobHandle) {
    cronJobHandle.stop();
    console.log('[Scheduler] ⏹️ Scheduler parado');
  }
}

/**
 * Retorna a instância do processador (para testes ou chamadas manuais)
 */
export function getRescheduleProcessor(): RescheduleSuggestionsProcessor {
  if (!rescheduleProcessor) {
    rescheduleProcessor = new RescheduleSuggestionsProcessor();
  }
  return rescheduleProcessor;
}

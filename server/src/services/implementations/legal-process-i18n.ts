import type { LegalProcessStatus } from '@enums';

const STATUS_PT_BR: Record<LegalProcessStatus, string> = {
  OPEN: 'Aberto',
  UNDER_ANALYSIS: 'Em análise',
  AWAITING_DOCUMENT: 'Aguardando documento',
  COMPLETED: 'Concluído',
  ARCHIVED: 'Arquivado',
};

export function formatLegalProcessStatus(status: string): string {
  return (STATUS_PT_BR as Record<string, string>)[status] ?? status;
}

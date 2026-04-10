import type { TipoCaso } from '@enums';

export interface CreateProcessoDTO {
  clienteId: string;
  advogadoId?: string;
  titulo: string;
  descricao?: string;
  tipoCaso: TipoCaso;
  numeroProcesso?: string;
}

/** DTO para atualização de status de um processo (gera evento na timeline) */
export interface UpdateProcessoStatusDTO {
  processoId: string;
  novoStatus: string;
  notaAdvogado?: string;
  atualizadoPorId: string;
}

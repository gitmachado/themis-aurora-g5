import type { TipoCaso, StatusProcesso } from '@enums';

export interface Processo {
  id: string;
  clienteId: string;
  advogadoId: string | null;
  titulo: string;
  descricao: string | null;
  statusAtual: StatusProcesso;
  numeroProcesso: string | null;
  tipoCaso: TipoCaso;
  ultimaNota: string | null;
  dataUltimaMovimentacao: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

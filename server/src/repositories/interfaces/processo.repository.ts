import type { Processo } from '@models';

export interface IProcessoRepository {
  findById(id: string): Promise<Processo | null>;
  findByClienteId(clienteId: string): Promise<Processo[]>;
  findByAdvogadoId(advogadoId: string): Promise<Processo[]>;
  create(processo: Omit<Processo, 'id' | 'createdAt' | 'updatedAt'>): Promise<Processo>;
  updateStatus(id: string, novoStatus: string): Promise<Processo>;
  update(id: string, data: Partial<Processo>): Promise<Processo>;
  delete(id: string): Promise<void>;
}

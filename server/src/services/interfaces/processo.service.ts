import type { Processo } from '@models';
import type { CreateProcessoDTO, UpdateProcessoStatusDTO } from '@dtos';

export interface IProcessoService {
  create(dto: CreateProcessoDTO): Promise<Processo>;
  updateStatus(dto: UpdateProcessoStatusDTO): Promise<Processo>;
  getByClienteId(clienteId: string): Promise<Processo[]>;
  getById(id: string): Promise<Processo | null>;
}

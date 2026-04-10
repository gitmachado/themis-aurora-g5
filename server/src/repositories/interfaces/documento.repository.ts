import type { Documento } from '@models';

export interface IDocumentoRepository {
  findById(id: string): Promise<Documento | null>;
  findByProcessoId(processoId: string): Promise<Documento[]>;
  create(documento: Omit<Documento, 'id' | 'createdAt'>): Promise<Documento>;
  delete(id: string): Promise<void>;
}

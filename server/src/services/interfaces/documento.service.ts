import type { Documento } from '@models';
import type { CreateDocumentoDTO } from '@dtos';

/** Formatos aceitos para upload de documentos */
export const ALLOWED_MIME_TYPES = ['application/pdf', 'image/png', 'image/jpeg'] as const;
/** Tamanho máximo de arquivo: 10MB */
export const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;

export interface IDocumentoService {
  upload(dto: CreateDocumentoDTO): Promise<Documento>;
  validateFile(tamanhoBytes: number, tipoMime: string): boolean;
  getByProcesso(processoId: string): Promise<Documento[]>;
  delete(id: string): Promise<void>;
}

import type { Document } from '@models';
import type { CreateDocumentDTO } from '@dtos';

/** Allowed formats for document upload */
export const ALLOWED_MIME_TYPES = ['application/pdf', 'image/png', 'image/jpeg'] as const;
/** Maximum file size: 10MB */
export const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024;

export interface IDocumentService {
  upload(dto: CreateDocumentDTO): Promise<Document>;
  validateFile(sizeBytes: number, mimeType: string): boolean;
  getByLegalProcess(legalProcessId: string): Promise<Document[]>;
  getById(id: string): Promise<Document | null>;
  getByFileName(fileName: string): Promise<Document | null>;
  delete(id: string): Promise<void>;
}

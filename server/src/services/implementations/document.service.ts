import { IDocumentService, ALLOWED_MIME_TYPES, MAX_FILE_SIZE_BYTES } from '../interfaces/document.service';
import { IDocumentRepository } from '../../repositories/interfaces/document.repository';
import type { Document } from '@models';
import type { CreateDocumentDTO } from '@dtos';
import { ValidationError, NotFoundError } from './errors';

export class DocumentService implements IDocumentService {
  constructor(private readonly documentRepository: IDocumentRepository) {}

  async upload(dto: CreateDocumentDTO): Promise<Document> {
    // In a real scenario, the file would be handled by a middleware (like multer) 
    // and its metadata passed here. We assume validation happened or we do it here.
    
    return this.documentRepository.create({
      legalProcessId: dto.legalProcessId,
      fileName: dto.fileName,
      fileUrl: dto.fileUrl,
      mimeType: dto.mimeType || 'application/octet-stream',
      sizeBytes: dto.sizeBytes || null,
      sentById: dto.sentById,
    });
  }

  validateFile(sizeBytes: number, mimeType: string): boolean {
    if (sizeBytes > MAX_FILE_SIZE_BYTES) {
      throw new ValidationError(`Arquivo excede o limite de ${MAX_FILE_SIZE_BYTES / (1024 * 1024)}MB`);
    }

    if (!ALLOWED_MIME_TYPES.includes(mimeType as any)) {
      throw new ValidationError(`Formato de arquivo não permitido. Formatos aceitos: ${ALLOWED_MIME_TYPES.join(', ')}`);
    }

    return true;
  }

  async getByLegalProcess(legalProcessId: string): Promise<Document[]> {
    return this.documentRepository.findByLegalProcessId(legalProcessId);
  }

  async delete(id: string): Promise<void> {
    const document = await this.documentRepository.findById(id);
    if (!document) {
      throw new NotFoundError('Documento não encontrado');
    }
    // In a real scenario, we would also delete the file from storage (S3, etc.)
    await this.documentRepository.delete(id);
  }
}

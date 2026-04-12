import type { Document } from '@models';

export interface IDocumentRepository {
  findById(id: string): Promise<Document | null>;
  findByFileName(fileName: string): Promise<Document | null>;
  findByLegalProcessId(legalProcessId: string): Promise<Document[]>;
  create(document: Omit<Document, 'id' | 'createdAt' | 'updatedAt'>): Promise<Document>;
  delete(id: string): Promise<void>;
}

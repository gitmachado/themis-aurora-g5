import { IDocumentRepository } from '../interfaces/document.repository';
import type { Document } from '@models';
import { dbGet, dbAll, dbRun } from '../../config/database';

export class DocumentRepository implements IDocumentRepository {
  private readonly selectFields = `
    id, 
    legal_process_id as "legalProcessId", 
    file_name as "fileName", 
    file_url as "fileUrl", 
    size_bytes as "sizeBytes", 
    mime_type as "mimeType", 
    sent_by_id as "sentById", 
    created_at as "createdAt", 
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<Document | null> {
    return dbGet<Document>(`SELECT ${this.selectFields} FROM documents WHERE id = $1`, [id]);
  }

  async findByFileName(fileName: string): Promise<Document | null> {
    return dbGet<Document>(
      `SELECT ${this.selectFields}
       FROM documents
       WHERE file_name = $1 OR file_url = $2`,
      [fileName, `/uploads/${fileName}`]
    );
  }

  async findByLegalProcessId(legalProcessId: string): Promise<Document[]> {
    return dbAll<Document>(
      `SELECT ${this.selectFields}
       FROM documents
       WHERE legal_process_id = $1
       ORDER BY created_at DESC`,
      [legalProcessId]
    );
  }

  async create(document: Omit<Document, 'id' | 'createdAt' | 'updatedAt'>): Promise<Document> {
    return (await dbGet<Document>(
      `INSERT INTO documents (legal_process_id, file_name, file_url, size_bytes, mime_type, sent_by_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING ${this.selectFields}`,
      [document.legalProcessId, document.fileName, document.fileUrl, document.sizeBytes, document.mimeType, document.sentById]
    ))!;
  }

  async delete(id: string): Promise<void> {
    await dbRun('DELETE FROM documents WHERE id = $1', [id]);
  }
}

import { ILegalProcessRepository } from '../interfaces/legal-process.repository';
import type { LegalProcess } from '@models';
import { dbGet, dbAll, dbRun } from '../../config/database';

export class LegalProcessRepository implements ILegalProcessRepository {
  private readonly selectFields = `
    id, 
    client_id as "clientId", 
    lawyer_id as "lawyerId", 
    title, 
    description, 
    current_status as "currentStatus", 
    process_number as "processNumber", 
    case_type as "caseType", 
    last_note as "lastNote", 
    last_movement_date as "lastMovementDate", 
    created_at as "createdAt", 
    updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<LegalProcess | null> {
    return dbGet<LegalProcess>(`SELECT ${this.selectFields} FROM legal_processes WHERE id = $1`, [id]);
  }

  async findByClientId(clientId: string): Promise<LegalProcess[]> {
    return dbAll<LegalProcess>(`SELECT ${this.selectFields} FROM legal_processes WHERE client_id = $1`, [clientId]);
  }

  async findByLawyerId(lawyerId: string): Promise<LegalProcess[]> {
    return dbAll<LegalProcess>(`SELECT ${this.selectFields} FROM legal_processes WHERE lawyer_id = $1`, [lawyerId]);
  }

  async create(legalProcess: Omit<LegalProcess, 'id' | 'createdAt' | 'updatedAt'>): Promise<LegalProcess> {
    return (await dbGet<LegalProcess>(
      `INSERT INTO legal_processes (client_id, lawyer_id, title, description, current_status, process_number, case_type, last_note, last_movement_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING ${this.selectFields}`,
      [
        legalProcess.clientId, legalProcess.lawyerId, legalProcess.title, 
        legalProcess.description, legalProcess.currentStatus, legalProcess.processNumber, 
        legalProcess.caseType, legalProcess.lastNote, legalProcess.lastMovementDate
      ]
    ))!;
  }

  async updateStatus(id: string, newStatus: string): Promise<LegalProcess> {
    return (await dbGet<LegalProcess>(
      `UPDATE legal_processes SET current_status = $1 WHERE id = $2 RETURNING ${this.selectFields}`,
      [newStatus, id]
    ))!;
  }

  async update(id: string, data: Partial<LegalProcess>): Promise<LegalProcess> {
    const fields = Object.keys(data).filter(key => key !== 'id' && key !== 'createdAt' && key !== 'updatedAt');
    const setClause = fields
      .map((key, index) => {
        const column = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
        return `${column} = $${index + 2}`;
      })
      .join(', ');

    const values = fields.map(key => (data as any)[key]);

    return (await dbGet<LegalProcess>(
      `UPDATE legal_processes SET ${setClause} WHERE id = $1 RETURNING ${this.selectFields}`,
      [id, ...values]
    ))!;
  }

  async delete(id: string): Promise<void> {
    await dbRun('DELETE FROM legal_processes WHERE id = $1', [id]);
  }
}

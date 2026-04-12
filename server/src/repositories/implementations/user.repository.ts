import { IUserRepository } from '../interfaces/user.repository';
import type { User } from '@models';
import { dbGet, dbRun } from '../../config/database';

export class UserRepository implements IUserRepository {
  private readonly userSelect = `
    id, name, whatsapp_number as "whatsappNumber", cpf, email, role, 
    password_hash as "passwordHash", fcm_token as "fcmToken", 
    notification_preferences as "notificationPreferences", 
    created_at as "createdAt", updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE id = $1`,
      [id]
    );
  }

  async findByWhatsapp(whatsappNumber: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE whatsapp_number = $1`,
      [whatsappNumber]
    );
  }

  async findByCpf(cpf: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE cpf = $1`,
      [cpf]
    );
  }

  async create(user: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> {
    return (await dbGet<User>(
      `INSERT INTO users (name, whatsapp_number, cpf, email, role, password_hash, fcm_token, notification_preferences)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING ${this.userSelect}`,
      [user.name, user.whatsappNumber, user.cpf, user.email, user.role, user.passwordHash, user.fcmToken, user.notificationPreferences]
    ))!;
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    const fields = Object.keys(data).filter(key => key !== 'id' && key !== 'createdAt' && key !== 'updatedAt');
    const setClause = fields
      .map((key, index) => {
        const column = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
        return `${column} = $${index + 2}`;
      })
      .join(', ');

    const values = fields.map(key => data[key as keyof User]);

    return (await dbGet<User>(
      `UPDATE users SET ${setClause} WHERE id = $1 
       RETURNING ${this.userSelect}`,
      [id, ...values]
    ))!;
  }

  async delete(id: string): Promise<void> {
    await dbRun('DELETE FROM users WHERE id = $1', [id]);
  }
}

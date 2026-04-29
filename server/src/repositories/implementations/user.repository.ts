import { IUserRepository } from '../interfaces/user.repository';
import type { User } from '@models';
import { dbAll, dbGet, dbRun } from '../../config/database';

export class UserRepository implements IUserRepository {
  private readonly userSelect = `
    id, name, whatsapp_number as "whatsappNumber", cpf, email,
    supabase_user_id as "supabaseUserId", avatar_url as "avatarUrl", role,
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

  async findByEmail(email: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE lower(email) = lower($1)`,
      [email]
    );
  }

  async findBySupabaseUserId(supabaseUserId: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE supabase_user_id = $1`,
      [supabaseUserId]
    );
  }

  async findByCpfOrWhatsapp(identifier: string): Promise<User[]> {
    return dbAll<User>(
      `SELECT ${this.userSelect}
       FROM users
       WHERE regexp_replace(COALESCE(cpf, ''), '\\D', '', 'g') = $1
          OR regexp_replace(whatsapp_number, '\\D', '', 'g') = $1`,
      [identifier]
    );
  }

  async findClientsByLawyerId(lawyerId: string): Promise<User[]> {
    return dbAll<User>(
      `SELECT DISTINCT
        users.id,
        users.name,
        users.whatsapp_number as "whatsappNumber",
        users.cpf,
        users.email,
        users.supabase_user_id as "supabaseUserId",
        users.avatar_url as "avatarUrl",
        users.role,
        users.password_hash as "passwordHash",
        users.fcm_token as "fcmToken",
        users.notification_preferences as "notificationPreferences",
        users.created_at as "createdAt",
        users.updated_at as "updatedAt"
       FROM users
       INNER JOIN legal_processes ON legal_processes.client_id = users.id
       WHERE legal_processes.lawyer_id = $1
         AND users.role = 'CLIENT'
       ORDER BY users.name ASC`,
      [lawyerId]
    );
  }

  async findClientByLawyerId(lawyerId: string, clientId: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT DISTINCT
        users.id,
        users.name,
        users.whatsapp_number as "whatsappNumber",
        users.cpf,
        users.email,
        users.supabase_user_id as "supabaseUserId",
        users.avatar_url as "avatarUrl",
        users.role,
        users.password_hash as "passwordHash",
        users.fcm_token as "fcmToken",
        users.notification_preferences as "notificationPreferences",
        users.created_at as "createdAt",
        users.updated_at as "updatedAt"
       FROM users
       INNER JOIN legal_processes ON legal_processes.client_id = users.id
       WHERE legal_processes.lawyer_id = $1
         AND users.id = $2
         AND users.role = 'CLIENT'`,
      [lawyerId, clientId]
    );
  }

  async create(user: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> {
    return (await dbGet<User>(
      `INSERT INTO users (name, whatsapp_number, cpf, email, supabase_user_id, avatar_url, role, password_hash, fcm_token, notification_preferences)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING ${this.userSelect}`,
      [
        user.name,
        user.whatsappNumber,
        user.cpf,
        user.email,
        user.supabaseUserId,
        user.avatarUrl,
        user.role,
        user.passwordHash,
        user.fcmToken,
        user.notificationPreferences,
      ]
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

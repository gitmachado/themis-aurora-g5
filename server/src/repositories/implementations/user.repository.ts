import { IUserRepository } from '../interfaces/user.repository';
import type { User } from '@models';
import { dbAll, dbGet, dbRun } from '../../config/database';

export class UserRepository implements IUserRepository {
  private readonly userSelect = `
    id, name, whatsapp_number as "whatsappNumber", cpf, email,
    avatar_url as "avatarUrl", role,
    password_hash as "passwordHash", fcm_token as "fcmToken",
    notification_preferences as "notificationPreferences",
    team_permissions as "teamPermissions",
    lawyer_admin_id as "lawyerAdminId",
    oab_number as "oabNumber",
    specialty,
    must_change_password as "mustChangePassword",
    created_at as "createdAt", updated_at as "updatedAt"
  `;

  async findById(id: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect} FROM users WHERE id = $1`,
      [id]
    );
  }

  async findByWhatsapp(whatsappNumber: string): Promise<User | null> {
    // 1. Busca exata (com ou sem sufixo @s.whatsapp.net)
    const user = await dbGet<User>(`SELECT ${this.userSelect} FROM users WHERE whatsapp_number = $1`, [whatsappNumber]);
    if (user) return user;

    // 2. Busca normalizada (apenas dígitos)
    const normalized = whatsappNumber.split('@')[0].replace(/\D/g, '');
    if (!normalized) return null;

    // Se o número tem o '9' do Brasil (13 dígitos com 55), tenta também sem o '9' e vice-versa
    let alternative = '';
    if (normalized.startsWith('55') && normalized.length === 13 && normalized[4] === '9') {
      alternative = '55' + normalized.substring(2, 4) + normalized.substring(5); // Remove o 9
    } else if (normalized.startsWith('55') && normalized.length === 12) {
      alternative = '55' + normalized.substring(2, 4) + '9' + normalized.substring(4); // Adiciona o 9
    }

    return dbGet<User>(`
      SELECT ${this.userSelect} 
      FROM users 
      WHERE regexp_replace(whatsapp_number, '\\D', '', 'g') = $1
         OR ( $3 != '' AND regexp_replace(whatsapp_number, '\\D', '', 'g') = $3 )
         OR whatsapp_number LIKE $2
      LIMIT 1
    `, [normalized, `%${normalized}%`, alternative]);
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
        users.avatar_url as "avatarUrl",
        users.role,
        users.password_hash as "passwordHash",
        users.fcm_token as "fcmToken",
        users.notification_preferences as "notificationPreferences",
        users.team_permissions as "teamPermissions",
        users.lawyer_admin_id as "lawyerAdminId",
        users.oab_number as "oabNumber",
        users.specialty,
        users.must_change_password as "mustChangePassword",
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
        users.avatar_url as "avatarUrl",
        users.role,
        users.password_hash as "passwordHash",
        users.fcm_token as "fcmToken",
        users.notification_preferences as "notificationPreferences",
        users.team_permissions as "teamPermissions",
        users.lawyer_admin_id as "lawyerAdminId",
        users.oab_number as "oabNumber",
        users.specialty,
        users.must_change_password as "mustChangePassword",
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

  async findAllLawyers(): Promise<User[]> {
    return dbAll<User>(
      `SELECT ${this.userSelect} FROM users WHERE role IN ('LAWYER', 'LAWYER_ADMIN')`
    );
  }

  async create(user: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> {
    return (await dbGet<User>(
      `INSERT INTO users (
         name, whatsapp_number, cpf, email, avatar_url, role,
         password_hash, fcm_token, notification_preferences,
         team_permissions, lawyer_admin_id, oab_number, specialty,
         must_change_password
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING ${this.userSelect}`,
      [
        user.name,
        user.whatsappNumber,
        user.cpf,
        user.email,
        user.avatarUrl,
        user.role,
        user.passwordHash,
        user.fcmToken,
        user.notificationPreferences,
        user.teamPermissions ?? {},
        user.lawyerAdminId ?? null,
        user.oabNumber ?? null,
        user.specialty ?? null,
        user.mustChangePassword ?? false,
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

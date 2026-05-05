import { ITeamRepository } from '../interfaces/team.repository';
import type { User } from '@models';
import type { TeamMemberStatsDTO } from '@dtos';
import { dbAll, dbGet, dbRun } from '../../config/database';

export class TeamRepository implements ITeamRepository {
  private readonly userSelect = `
    id, name, whatsapp_number as "whatsappNumber", cpf, email,
    avatar_url as "avatarUrl", role,
    password_hash as "passwordHash", fcm_token as "fcmToken",
    notification_preferences as "notificationPreferences",
    team_permissions as "teamPermissions",
    lawyer_admin_id as "lawyerAdminId",
    oab_number as "oabNumber",
    specialty,
    created_at as "createdAt", updated_at as "updatedAt"
  `;

  async findByAdminId(adminId: string): Promise<User[]> {
    return dbAll<User>(
      `SELECT ${this.userSelect}
       FROM users
       WHERE lawyer_admin_id = $1 AND role = 'LAWYER'
       ORDER BY name ASC`,
      [adminId]
    );
  }

  async findOneByAdminId(adminId: string, lawyerId: string): Promise<User | null> {
    return dbGet<User>(
      `SELECT ${this.userSelect}
       FROM users
       WHERE lawyer_admin_id = $1 AND id = $2 AND role = 'LAWYER'`,
      [adminId, lawyerId]
    );
  }

  async getStats(lawyerId: string): Promise<TeamMemberStatsDTO> {
    const row = await dbGet<{
      activeProcesses: string;
      completedProcesses: string;
      assignedLeads: string;
      convertedLeads: string;
      lastActivityAt: Date | null;
    }>(
      `SELECT
         (SELECT COUNT(*)::int FROM legal_processes
            WHERE lawyer_id = $1 AND current_status NOT IN ('COMPLETED', 'ARCHIVED')) AS "activeProcesses",
         (SELECT COUNT(*)::int FROM legal_processes
            WHERE lawyer_id = $1 AND current_status = 'COMPLETED') AS "completedProcesses",
         (SELECT COUNT(*)::int FROM leads
            WHERE assigned_lawyer_id = $1 AND status IN ('PENDING', 'IN_CONTACT')) AS "assignedLeads",
         (SELECT COUNT(*)::int FROM leads
            WHERE assigned_lawyer_id = $1 AND status = 'CONVERTED') AS "convertedLeads",
         (SELECT MAX(created_at) FROM timeline_events
            WHERE created_by_id = $1) AS "lastActivityAt"
      `,
      [lawyerId]
    );

    return {
      activeProcesses: Number(row?.activeProcesses ?? 0),
      completedProcesses: Number(row?.completedProcesses ?? 0),
      assignedLeads: Number(row?.assignedLeads ?? 0),
      convertedLeads: Number(row?.convertedLeads ?? 0),
      lastActivityAt: row?.lastActivityAt ?? null,
    };
  }

  async updatePermissions(
    lawyerId: string,
    permissions: Record<string, boolean>
  ): Promise<User> {
    return (await dbGet<User>(
      `UPDATE users SET team_permissions = $2::jsonb
       WHERE id = $1 AND role = 'LAWYER'
       RETURNING ${this.userSelect}`,
      [lawyerId, JSON.stringify(permissions)]
    ))!;
  }

  async remove(lawyerId: string): Promise<void> {
    await dbRun(
      `DELETE FROM users WHERE id = $1 AND role = 'LAWYER'`,
      [lawyerId]
    );
  }

  async countActiveProcesses(lawyerId: string): Promise<number> {
    const row = await dbGet<{ count: string }>(
      `SELECT COUNT(*)::int AS count
       FROM legal_processes
       WHERE lawyer_id = $1 AND current_status NOT IN ('COMPLETED', 'ARCHIVED')`,
      [lawyerId]
    );
    return Number(row?.count ?? 0);
  }
}

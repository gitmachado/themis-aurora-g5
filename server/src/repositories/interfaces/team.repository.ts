import type { User } from '@models';
import type { TeamMemberStatsDTO } from '@dtos';

export interface TeamMemberRow {
  user: User;
  stats: TeamMemberStatsDTO;
}

export interface ITeamRepository {
  findByAdminId(adminId: string): Promise<User[]>;
  findOneByAdminId(adminId: string, lawyerId: string): Promise<User | null>;
  getStats(lawyerId: string): Promise<TeamMemberStatsDTO>;
  updatePermissions(lawyerId: string, permissions: Record<string, boolean>): Promise<User>;
  remove(lawyerId: string): Promise<void>;
  countActiveProcesses(lawyerId: string): Promise<number>;
}

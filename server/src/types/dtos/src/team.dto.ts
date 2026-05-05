import type { CaseType } from '@enums';

export interface TeamMemberStatsDTO {
  activeProcesses: number;
  completedProcesses: number;
  assignedLeads: number;
  convertedLeads: number;
  lastActivityAt: Date | null;
}

export interface TeamMemberDTO {
  id: string;
  name: string;
  email: string | null;
  whatsappNumber: string;
  avatarUrl: string | null;
  oabNumber: string | null;
  specialty: string | null;
  permissions: Record<string, boolean>;
  joinedAt: Date;
  isActive: boolean;
  stats: TeamMemberStatsDTO;
}

export interface CreateTeamMemberDTO {
  name: string;
  email: string;
  whatsappNumber: string;
  oabNumber: string;
  specialty: CaseType;
}

export interface CreateTeamMemberResponseDTO {
  member: TeamMemberDTO;
  tempPassword: string;
}

export interface UpdateTeamPermissionsDTO {
  permissions: Record<string, boolean>;
}

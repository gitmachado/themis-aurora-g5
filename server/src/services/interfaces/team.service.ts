import type {
  TeamMemberDTO,
  CreateTeamMemberDTO,
  CreateTeamMemberResponseDTO,
} from '@dtos';

export interface ITeamService {
  listTeam(adminId: string): Promise<TeamMemberDTO[]>;
  getMember(adminId: string, lawyerId: string): Promise<TeamMemberDTO>;
  addMember(
    adminId: string,
    dto: CreateTeamMemberDTO
  ): Promise<CreateTeamMemberResponseDTO>;
  updatePermissions(
    adminId: string,
    lawyerId: string,
    permissions: Record<string, boolean>
  ): Promise<TeamMemberDTO>;
  removeMember(adminId: string, lawyerId: string): Promise<void>;
}

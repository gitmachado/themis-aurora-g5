import { Response, NextFunction, RequestHandler } from 'express';
import { ITeamService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import {
  CreateTeamMemberDTO,
  CreateTeamMemberResponseDTO,
  TeamMemberDTO,
  UpdateTeamPermissionsDTO,
} from '@dtos';

export class TeamController {
  constructor(private readonly teamService: ITeamService) {}

  list: RequestHandler<any, TeamMemberDTO[]> = async (
    req: AuthRequest<any, TeamMemberDTO[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const team = await this.teamService.listTeam(req.user!.id);
      return res.status(200).json(team);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, TeamMemberDTO> = async (
    req: AuthRequest<{ id: string }, TeamMemberDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const member = await this.teamService.getMember(req.user!.id, req.params.id);
      return res.status(200).json(member);
    } catch (error) {
      next(error);
    }
  };

  create: RequestHandler<
    any,
    CreateTeamMemberResponseDTO,
    CreateTeamMemberDTO
  > = async (
    req: AuthRequest<any, CreateTeamMemberResponseDTO, CreateTeamMemberDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const result = await this.teamService.addMember(req.user!.id, req.body);
      return res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  };

  updatePermissions: RequestHandler<
    { id: string },
    TeamMemberDTO,
    UpdateTeamPermissionsDTO
  > = async (
    req: AuthRequest<{ id: string }, TeamMemberDTO, UpdateTeamPermissionsDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const member = await this.teamService.updatePermissions(
        req.user!.id,
        req.params.id,
        req.body.permissions
      );
      return res.status(200).json(member);
    } catch (error) {
      next(error);
    }
  };

  remove: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      await this.teamService.removeMember(req.user!.id, req.params.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

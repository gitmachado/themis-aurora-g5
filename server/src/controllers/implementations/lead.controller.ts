import { Request, Response, NextFunction, RequestHandler } from 'express';
import { ILeadService } from '@services';
import { Lead, User } from '@models';
import { CreateLeadDTO } from '@dtos';
import { LeadStatus } from '@enums';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';

interface DiscardLeadBody {
  reason?: string;
}

const validLeadStatuses: LeadStatus[] = [
  'PENDING',
  'IN_CONTACT',
  'CONVERTED',
  'DISCARDED',
];

export class LeadController {
  constructor(private readonly leadService: ILeadService) {}

  listAll: RequestHandler<any, Lead[], any, { status?: string }> = async (
    req: Request<any, Lead[], any, { status?: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const status = req.query.status?.toUpperCase();
      const leads =
        status && validLeadStatuses.includes(status as LeadStatus)
          ? await this.leadService.getByStatus(status as LeadStatus)
          : await this.leadService.getPending();
      return res.status(200).json(leads);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, Lead> = async (
    req: Request<{ id: string }, Lead>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const lead = await this.leadService.getById(req.params.id);
      return res.status(200).json(lead!);
    } catch (error) {
      next(error);
    }
  };

  create: RequestHandler<any, Lead, CreateLeadDTO> = async (
    req: Request<any, Lead, CreateLeadDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const lead = await this.leadService.createFromWhatsapp(req.body);
      return res.status(201).json(lead);
    } catch (error) {
      next(error);
    }
  };

  convert: RequestHandler<{ id: string }, User> = async (
    req: Request<{ id: string }, User>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const result = await this.leadService.convertToClient({
        leadId: req.params.id,
        lawyerId: (req as AuthRequest<{ id: string }, User>).user!.id,
      });
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };

  discard: RequestHandler<{ id: string }, Lead, DiscardLeadBody> = async (
    req: Request<{ id: string }, Lead, DiscardLeadBody>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const result = await this.leadService.discard(req.params.id, req.body.reason);
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}

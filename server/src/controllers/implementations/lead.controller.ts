import { Request, Response, NextFunction, RequestHandler } from 'express';
import { ILeadService } from '@services';
import { Lead, User } from '@models';
import { CreateLeadDTO } from '@dtos';

export class LeadController {
  constructor(private readonly leadService: ILeadService) {}

  listAll: RequestHandler<any, Lead[]> = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const leads = await this.leadService.getPending();
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
      const result = await this.leadService.convertToClient({ leadId: req.params.id });
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}

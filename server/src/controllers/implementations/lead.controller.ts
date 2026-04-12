import { Request, Response, NextFunction } from 'express';
import { LeadService, AuthService, NotificationService } from '@services';
import { LeadRepository, UserRepository, NotificationRepository } from '@repositories';

export class LeadController {
  private leadService: LeadService;

  constructor() {
    const leadRepository = new LeadRepository();
    const userRepository = new UserRepository();
    const authService = new AuthService(userRepository);
    const notificationRepository = new NotificationRepository();
    const notificationService = new NotificationService(notificationRepository);
    
    this.leadService = new LeadService(
      leadRepository, 
      userRepository, 
      authService, 
      notificationService
    );
  }

  listAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const leads = await this.leadService.getPending();
      return res.status(200).json(leads);
    } catch (error) {
      next(error);
    }
  };

  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const lead = await this.leadService.getById(req.params.id as string);
      return res.status(200).json(lead);
    } catch (error) {
      next(error);
    }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const lead = await this.leadService.createFromWhatsapp(req.body);
      return res.status(201).json(lead);
    } catch (error) {
      next(error);
    }
  };

  convert = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.leadService.convertToClient({ leadId: req.params.id as string });
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  };
}

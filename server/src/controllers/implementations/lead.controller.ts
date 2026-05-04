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
          : await this.leadService.getAll();
      return res.status(200).json(leads);
    } catch (error) {
      next(error);
    }
  };

  listPending: RequestHandler<any, Lead[]> = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const leads = await this.leadService.getPending();
      console.log(`[LeadController] Pending leads found: ${leads.length}`);
      if (leads.length > 0) {
        console.log(`[LeadController] First lead ID: ${leads[0].id}, Name: ${leads[0].name}`);
      }
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

  getByWhatsapp: RequestHandler<{ whatsappNumber: string }, Lead> = async (
    req: Request<{ whatsappNumber: string }, Lead>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const lead = await this.leadService.getByWhatsapp(req.params.whatsappNumber);
      if (!lead) return res.status(404).json({ message: 'Lead não encontrado' });
      return res.status(200).json(lead);
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

  resumeAI: RequestHandler<any, any, { whatsappNumber: string }> = async (
    req: Request<any, any, { whatsappNumber: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.body;
      await this.leadService.resumeAISupport(whatsappNumber);
      return res.status(200).json({ message: 'Atendimento retomado pela IA com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  startHandoff: RequestHandler<any, any, { whatsappNumber: string }> = async (
    req: Request<any, any, { whatsappNumber: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.body;
      await this.leadService.startHandoffSupport(whatsappNumber);
      return res.status(200).json({ message: 'Handoff para humano iniciado com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  assign: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { id } = req.params;
      const lawyerId = req.user!.id;
      await this.leadService.assignToLawyer(id, lawyerId);
      return res.status(200).json({ message: 'Lead atribuído com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  release: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { id } = req.params;
      await this.leadService.releaseFromLawyer(id);
      return res.status(200).json({ message: 'Lead liberado com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  update: RequestHandler<{ id: string }, Lead, Partial<CreateLeadDTO>> = async (
    req: Request<{ id: string }, Lead, Partial<CreateLeadDTO>>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      console.log(`[LeadController] Recebido PATCH para lead ${req.params.id}`);
      console.log(`[LeadController] Body: ${JSON.stringify(req.body)}`);
      const lead = await this.leadService.updateLeadData(req.params.id, req.body);
      console.log(`[LeadController] Lead atualizado com sucesso: ${lead.id}`);
      return res.status(200).json(lead);
    } catch (error) {
      console.error(`[LeadController] Erro no update: ${error}`);
      next(error);
    }
  };

  delete: RequestHandler<{ id: string }> = async (
    req: Request<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      await this.leadService.deleteLead(req.params.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

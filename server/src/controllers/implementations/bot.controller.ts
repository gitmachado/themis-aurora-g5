import { Request, Response, NextFunction, RequestHandler } from 'express';
import { IUserService, IAppointmentService } from '@services';
import { ILegalProcessService } from '@services';
import { ITimelineService } from '../../services/interfaces/timeline.service';
import { IConfigurationService } from '../../services/interfaces/configuration.service';
import { INotificationService } from '@services';
import { NotFoundError } from '../../services/implementations/errors';
import type { LegalProcess, User } from '@models';
import { ILeadRepository } from '@repositories';

/**
 * Controller for bot-facing endpoints (API Key authentication).
 * These endpoints are consumed exclusively by the AI module.
 */
export class BotController {
  constructor(
    private readonly userService: IUserService,
    private readonly legalProcessService: ILegalProcessService,
    private readonly configurationService: IConfigurationService,
    private readonly notificationService: INotificationService,
    private readonly leadRepository: ILeadRepository,
    private readonly timelineService: ITimelineService,
    private readonly appointmentService: IAppointmentService,
  ) {}

  /**
   * B01 — GET /users/by-phone/:whatsappNumber
   * Checks if a WhatsApp number belongs to a registered user.
   */
  getUserByPhone: RequestHandler<{ whatsappNumber: string }> = async (
    req: Request<{ whatsappNumber: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.params;
      const user = await this.userService.getByWhatsapp(whatsappNumber);

      if (!user) {
        return res.status(200).json({ exists: false });
      }

      return res.status(200).json({
        exists: true,
        userId: user.id,
        name: user.name,
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B06 — GET /users/by-cpf/:cpf
   * Checks if a CPF belongs to a registered user.
   */
  getUserByCpf: RequestHandler<{ cpf: string }> = async (
    req: Request<{ cpf: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { cpf } = req.params;
      const user = await this.userService.getByCpf(cpf);

      if (!user) {
        return res.status(200).json({ exists: false });
      }

      return res.status(200).json({
        exists: true,
        userId: user.id,
        name: user.name,
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B05 — GET /leads/by-phone/:whatsappNumber
   * Checks if a WhatsApp number has a pending lead.
   */
  getLeadByPhone: RequestHandler<{ whatsappNumber: string }> = async (
    req: Request<{ whatsappNumber: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.params;
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);

      if (!lead) {
        return res.status(200).json({ exists: false });
      }

      return res.status(200).json({
        exists: true,
        id: lead.id,
        status: lead.status,
        name: lead.name,
        isAIPaused: lead.isAIPaused,
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B02 — GET /processes/by-phone/:whatsappNumber
   * Lists legal processes for a client identified by WhatsApp number.
   */
  getProcessesByPhone: RequestHandler<{ whatsappNumber: string }> = async (
    req: Request<{ whatsappNumber: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.params;
      const user = await this.userService.getByWhatsapp(whatsappNumber);

      if (!user) {
        return res.status(200).json({ processes: [] });
      }

      const processes = await this.legalProcessService.getByClientId(user.id);

      const processesWithTimeline = await Promise.all(
        processes.map(async (p: LegalProcess) => {
          const events = await this.timelineService.getByLegalProcess(p.id);
          // Sort descending by date and take the top 3
          const recentTimeline = events
            .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
            .slice(0, 3)
            .map(e => ({
              date: e.createdAt.toISOString(),
              type: e.type,
              content: e.content,
            }));

          return {
            id: p.id,
            title: p.title,
            caseType: p.caseType,
            processNumber: p.processNumber,
            status: p.currentStatus,
            lastUpdate: p.lastMovementDate,
            lawyerNote: p.lastNote,
            recentTimeline,
          };
        })
      );

      return res.status(200).json({ processes: processesWithTimeline });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B03 — GET /configurations
   * Returns the office configuration (tone of voice, service hours, away message).
   */
  getConfiguration: RequestHandler = async (
    _req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const config = await this.configurationService.getConfiguration();

      if (!config) {
        return res.status(200).json({
          toneOfVoice: 'Profissional e acolhedor',
          serviceHoursStart: '09:00',
          serviceHoursEnd: '18:00',
          awayMessage: 'Nosso horário de atendimento é de seg a sex, 9h às 18h.',
        });
      }

      return res.status(200).json({
        toneOfVoice: config.aiToneOfVoice || 'Profissional e acolhedor',
        serviceHoursStart: config.serviceHoursStart || '09:00',
        serviceHoursEnd: config.serviceHoursEnd || '18:00',
        awayMessage: config.awayMessage || 'Nosso horário de atendimento é de seg a sex, 9h às 18h.',
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B04 — POST /notifications (via API Key)
   * Allows the bot to send handoff notifications to lawyers.
   */
  createBotNotification: RequestHandler = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { type, message, whatsappNumber } = req.body;

      if (!type || !message || !whatsappNumber) {
        return res.status(400).json({
          error: 'Os campos type, message e whatsappNumber são obrigatórios',
        });
      }

      // Find the client by phone number to associate the notification
      const client = await this.userService.getByWhatsapp(whatsappNumber);
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);
      const clientName = client ? client.name : (lead ? lead.name : whatsappNumber);

      const extraData: any = { 
        whatsappNumber, 
        notificationType: type, 
        name: clientName 
      };
      if (lead) extraData.leadId = lead.id;

      // Find all lawyers to notify
      const lawyers = await this.userService.getAllLawyers();
      
      // Determine the notification type based on whether the client already exists
      const effectiveType = (client || (lead && lead.status === 'CONVERTED')) ? 'HUMAN_SUPPORT' : (type === 'NEW_LEAD' ? 'NEW_LEAD' : 'HUMAN_SUPPORT');

      const notifications = await Promise.all(lawyers.map(lawyer => 
        this.notificationService.send({
          userId: lawyer.id,
          type: effectiveType,
          title: effectiveType === 'NEW_LEAD' ? `Novo Lead: ${clientName}` : `Atenção: ${clientName}`,
          body: message,
          extraData,
        })
      ));

      return res.status(201).json(notifications[0]);
    } catch (error) {
      next(error);
    }
  };
  /**
   * B07 — POST /handoff/start
   * Notifies the backend to pause AI and switch to human support.
   */
  startHandoff: RequestHandler = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.body;
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);
      if (lead) {
        await this.leadRepository.update(lead.id, { isAIPaused: true });
      }
      return res.status(200).json({ success: true });
    } catch (error) {
      next(error);
    }
  };

  /**
   * B08 — POST /handoff/resume
   * Notifies the backend to resume AI support.
   */
  resumeAI: RequestHandler = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.body;
      const lead = await this.leadRepository.findByWhatsapp(whatsappNumber);
      if (lead) {
        await this.leadRepository.update(lead.id, { isAIPaused: false });
      }
      return res.status(200).json({ success: true });
    } catch (error) {
      next(error);
    }
  };
}


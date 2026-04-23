import { Request, Response, NextFunction, RequestHandler } from 'express';
import { IUserService } from '@services';
import { ILegalProcessService } from '@services';
import { IConfigurationService } from '../../services/interfaces/configuration.service';
import { INotificationService } from '@services';
import { NotFoundError } from '../../services/implementations/errors';
import type { LegalProcess, User } from '@models';

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

      return res.status(200).json({
        processes: processes.map((p: LegalProcess) => ({
          id: p.id,
          title: p.title,
          caseType: p.caseType,
          processNumber: p.processNumber,
          status: p.currentStatus,
          lastUpdate: p.lastMovementDate,
          lawyerNote: p.lastNote,
        })),
      });
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
      const clientName = client ? client.name : whatsappNumber;

      // Find all lawyers to notify
      // For now, we notify all lawyers by creating notifications.
      // The notification service handles sending push via FCM.
      const notification = await this.notificationService.send({
        // In a multi-lawyer system, this should route to the appropriate lawyer.
        // For MVP, we use a well-known lawyer ID from seed or the first lawyer.
        userId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', // seed lawyer ID
        type: 'HUMAN_SUPPORT',
        title: `Handoff: ${clientName}`,
        body: message,
        extraData: { whatsappNumber, notificationType: type },
      });

      return res.status(201).json(notification);
    } catch (error) {
      next(error);
    }
  };
}

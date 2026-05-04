import { Response, NextFunction, RequestHandler } from 'express';
import { IMessageService, IUserService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError } from '../../services/implementations/errors';
import { Message } from '@models';
import { CreateMessageDTO } from '@dtos';

export class MessageController {
  constructor(
    private readonly messageService: IMessageService,
    private readonly userService: IUserService
  ) {}

  getByWhatsapp: RequestHandler<{ whatsappNumber: string }, Message[]> = async (
    req: AuthRequest<{ whatsappNumber: string }, Message[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber } = req.params;
      const user = req.user!;

      // Privacy check: Clients can only see their own history
      if (user.role === 'CLIENT') {
        const dbUser = await this.userService.getById(user.id);
        const normalizedRequest = whatsappNumber.split('@')[0].replace(/\D/g, '');
        const normalizedDb = dbUser?.whatsappNumber.split('@')[0].replace(/\D/g, '');
        
        if (!dbUser || normalizedDb !== normalizedRequest) {
          throw new ForbiddenError('Você não tem permissão para visualizar este histórico');
        }
      }

      const messages = await this.messageService.getHistoryByPhone(whatsappNumber);
      return res.status(200).json(messages);
    } catch (error) {
      next(error);
    }
  };

  sync: RequestHandler<any, Message, CreateMessageDTO> = async (
    req: AuthRequest<any, Message, CreateMessageDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const message = await this.messageService.saveFromBot(req.body);
      return res.status(201).json(message);
    } catch (error) {
      next(error);
    }
  };

  send: RequestHandler<any, Message, { whatsappNumber: string; content: string }> = async (
    req: AuthRequest<any, Message, { whatsappNumber: string; content: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { whatsappNumber, content } = req.body;
      const user = req.user!;

      const message = await this.messageService.sendMessage({
        whatsappNumber,
        content,
        lawyerId: user.id,
      });

      return res.status(201).json(message);
    } catch (error) {
      next(error);
    }
  };
}

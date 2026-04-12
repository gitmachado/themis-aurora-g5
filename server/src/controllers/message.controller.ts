import { Request, Response, NextFunction, RequestHandler } from 'express';
import { MessageService } from '@services';
import { MessageRepository, UserRepository, LeadRepository } from '@repositories';
import { AuthRequest } from '../middlewares/authMiddleware';
import { ForbiddenError, NotFoundError } from '../services/implementations/errors';

export class MessageController {
  private messageService: MessageService;
  private userRepository: UserRepository;

  constructor() {
    const messageRepository = new MessageRepository();
    const leadRepository = new LeadRepository();
    this.userRepository = new UserRepository();
    this.messageService = new MessageService(
      messageRepository,
      this.userRepository,
      leadRepository
    );
  }

  getByWhatsapp: RequestHandler = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { whatsappNumber } = req.params;
      const user = req.user!;

      // Privacy check: Clients can only see their own history
      if (user.role === 'CLIENT') {
        const dbUser = await this.userRepository.findById(user.id);
        if (!dbUser || dbUser.whatsappNumber !== whatsappNumber) {
          throw new ForbiddenError('Você não tem permissão para visualizar este histórico');
        }
      }

      // If LAWYER or authorized CLIENT, get history by whatsappNumber
      // We need a method in service to get by phone
      const messages = await this.messageService.getHistoryByPhone(whatsappNumber as string);
      return res.status(200).json(messages);
    } catch (error) {
      next(error);
    }
  };

  sync: RequestHandler = async (req, res, next) => {
    try {
      const message = await this.messageService.saveFromBot(req.body);
      return res.status(201).json(message);
    } catch (error) {
      next(error);
    }
  };
}

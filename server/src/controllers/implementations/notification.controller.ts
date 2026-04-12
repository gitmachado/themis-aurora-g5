import { Response, NextFunction, RequestHandler } from 'express';
import { NotificationService } from '@services';
import { NotificationRepository } from '@repositories';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';

export class NotificationController {
  private notificationService: NotificationService;
  private notificationRepository: NotificationRepository;

  constructor() {
    this.notificationRepository = new NotificationRepository();
    this.notificationService = new NotificationService(this.notificationRepository);
  }

  listMyNotifications = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const notifications = await this.notificationService.getByUser(req.user!.id);
      return res.status(200).json(notifications);
    } catch (error) {
      next(error);
    }
  };

  markAsRead = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const notificationId = req.params.id as string;
      const user = req.user!;

      const notification = await this.notificationRepository.findById(notificationId);
      if (!notification) {
        throw new NotFoundError('Notificação não encontrada');
      }

      if (notification.userId !== user.id) {
        throw new ForbiddenError('Você não tem permissão para marcar esta notificação como lida');
      }

      await this.notificationService.markAsRead(notificationId);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  markAllAsRead: RequestHandler = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const user = req.user!;
      await this.notificationService.markAllAsRead(user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

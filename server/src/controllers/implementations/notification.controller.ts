import { Response, NextFunction, RequestHandler } from 'express';
import { INotificationService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import { Notification } from '@models';

export class NotificationController {
  constructor(private readonly notificationService: INotificationService) {}

  listMyNotifications: RequestHandler<any, Notification[]> = async (
    req: AuthRequest<any, Notification[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const notifications = await this.notificationService.getByUser(req.user!.id);
      return res.status(200).json(notifications);
    } catch (error) {
      next(error);
    }
  };

  markAsRead: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const notificationId = req.params.id;
      const user = req.user!;

      const notification = await this.notificationService.getById(notificationId);
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

  markAllAsRead: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      await this.notificationService.markAllAsRead(user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  delete: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    console.log('[NotificationController] delete called with id:', req.params.id);
    try {
      const notificationId = req.params.id;
      const user = req.user!;

      const notification = await this.notificationService.getById(notificationId);
      if (!notification) {
        throw new NotFoundError('Notificação não encontrada');
      }

      if (notification.userId !== user.id) {
        throw new ForbiddenError('Você não tem permissão para excluir esta notificação');
      }

      await this.notificationService.delete(notificationId);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  deleteMany: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    console.log('[NotificationController] deleteMany called with body:', req.body);
    try {
      const { ids } = req.body;
      const user = req.user!;

      if (!Array.isArray(ids)) {
        return res.status(400).json({ message: 'IDs devem ser uma array' });
      }

      await this.notificationService.deleteMany(ids, user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

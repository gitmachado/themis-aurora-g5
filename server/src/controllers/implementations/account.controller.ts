import { Response, NextFunction, RequestHandler } from 'express';
import { IUserService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { NotFoundError, ValidationError } from '../../services/implementations/errors';
import { AccountResponseDTO } from '@dtos';

interface UpdateNotificationPreferencesBody {
  notificationPreferences?: Record<string, boolean>;
}

export class AccountController {
  constructor(private readonly userService: IUserService) {}

  getCurrent: RequestHandler<any, AccountResponseDTO> = async (
    req: AuthRequest<any, AccountResponseDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = await this.userService.getById(req.user!.id);
      if (!user) {
        throw new NotFoundError('Conta não encontrada');
      }

      return res.status(200).json({
        id: user.id,
        name: user.name,
        whatsappNumber: user.whatsappNumber,
        cpf: user.cpf,
        email: user.email,
        role: user.role,
        notificationPreferences: user.notificationPreferences,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      });
    } catch (error) {
      next(error);
    }
  };

  updateNotificationPreferences: RequestHandler<
    any,
    AccountResponseDTO,
    UpdateNotificationPreferencesBody
  > = async (
    req: AuthRequest<any, AccountResponseDTO, UpdateNotificationPreferencesBody>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const preferences = req.body.notificationPreferences;
      if (!preferences || typeof preferences !== 'object' || Array.isArray(preferences)) {
        throw new ValidationError('Preferências de notificação inválidas');
      }

      for (const value of Object.values(preferences)) {
        if (typeof value !== 'boolean') {
          throw new ValidationError('Preferências de notificação devem ser booleanas');
        }
      }

      const user = await this.userService.update(req.user!.id, {
        notificationPreferences: preferences,
      });

      return res.status(200).json({
        id: user.id,
        name: user.name,
        whatsappNumber: user.whatsappNumber,
        cpf: user.cpf,
        email: user.email,
        role: user.role,
        notificationPreferences: user.notificationPreferences,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      });
    } catch (error) {
      next(error);
    }
  };
}

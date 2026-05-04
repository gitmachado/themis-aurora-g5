import { Response, NextFunction, RequestHandler } from 'express';
import fs from 'fs';
import { IUserService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { NotFoundError, ValidationError } from '../../services/implementations/errors';
import { AccountResponseDTO } from '@dtos';
import { User } from '@models';
import { IStorageProvider } from '../../utils/storage/storage.provider';

interface UpdateNotificationPreferencesBody {
  notificationPreferences?: Record<string, boolean>;
}

interface UpdateFcmTokenBody {
  fcmToken?: string | null;
}

const ALLOWED_AVATAR_MIME_TYPES = new Set([
  'image/png',
  'image/jpeg',
  'image/heic',
  'image/heif',
]);
const MAX_AVATAR_SIZE_BYTES = 5 * 1024 * 1024;

export class AccountController {
  constructor(
    private readonly userService: IUserService,
    private readonly storageProvider: IStorageProvider
  ) {}

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

      return res.status(200).json(await this.toAccountResponse(user));
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

      return res.status(200).json(await this.toAccountResponse(user));
    } catch (error) {
      next(error);
    }
  };

  updateFcmToken: RequestHandler<
    any,
    AccountResponseDTO,
    UpdateFcmTokenBody
  > = async (
    req: AuthRequest<any, AccountResponseDTO, UpdateFcmTokenBody>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      if (!('fcmToken' in req.body)) {
        throw new ValidationError('fcmToken é obrigatório');
      }

      const fcmToken = req.body.fcmToken;
      if (fcmToken !== null && typeof fcmToken !== 'string') {
        throw new ValidationError('fcmToken deve ser uma string ou null');
      }

      const user = await this.userService.update(req.user!.id, {
        fcmToken: fcmToken,
      });

      return res.status(200).json(await this.toAccountResponse(user));
    } catch (error) {
      next(error);
    }
  };

  uploadAvatar: RequestHandler<any, AccountResponseDTO> = async (
    req: AuthRequest<any, AccountResponseDTO>,
    res: Response,
    next: NextFunction
  ) => {
    const file = (req as any).file;
    try {
      if (!file) {
        throw new ValidationError('Nenhuma imagem enviada');
      }

      this.validateAvatarFile(file);

      const currentUser = await this.userService.getById(req.user!.id);
      if (!currentUser) {
        throw new NotFoundError('Conta não encontrada');
      }

      const previousAvatarUrl = currentUser.avatarUrl;
      let avatarUrl: string | null = null;

      try {
        avatarUrl = await this.storageProvider.saveFile(file, {
          folder: `avatars/${currentUser.id}`,
        });
      } catch (error) {
        await this.cleanupTempFile(file);
        throw error;
      }

      try {
        const user = await this.userService.update(currentUser.id, {
          avatarUrl,
        });

        if (previousAvatarUrl) {
          await this.storageProvider.deleteFile(previousAvatarUrl).catch(() => undefined);
        }

        return res.status(200).json(await this.toAccountResponse(user));
      } catch (error) {
        await this.storageProvider.deleteFile(avatarUrl).catch(() => undefined);
        throw error;
      }
    } catch (error) {
      if (file) {
        await this.cleanupTempFile(file);
      }
      next(error);
    }
  };

  private validateAvatarFile(file: { mimetype: string; size: number }): void {
    if (!ALLOWED_AVATAR_MIME_TYPES.has(file.mimetype)) {
      throw new ValidationError('Foto de perfil deve ser PNG, JPG, HEIC ou HEIF');
    }

    if (file.size > MAX_AVATAR_SIZE_BYTES) {
      throw new ValidationError('Foto de perfil deve ter no máximo 5MB');
    }
  }

  private async toAccountResponse(user: User): Promise<AccountResponseDTO> {
    const avatarUrl = user.avatarUrl
      ? await this.storageProvider.getAccessUrl(user.avatarUrl)
      : null;

    return {
      id: user.id,
      name: user.name,
      whatsappNumber: user.whatsappNumber,
      cpf: user.cpf,
      email: user.email,
      avatarUrl,
      role: user.role,
      notificationPreferences: user.notificationPreferences,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  private async cleanupTempFile(file: { path?: string }): Promise<void> {
    if (!file.path) return;
    await fs.promises.unlink(file.path).catch(() => undefined);
  }
}

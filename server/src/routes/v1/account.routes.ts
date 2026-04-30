import { Router } from 'express';
import multer from 'multer';
import { AccountController } from '../../controllers/implementations/account.controller';
import { UserRepository } from '@repositories';
import { UserService } from '@services';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { createStorageProvider } from '../../utils/storage/storage-provider.factory';
import { ensureDirectory, getTempDir } from '../../utils/storage/storage-paths';

const router = Router();

const userRepository = new UserRepository();
const userService = new UserService(userRepository);
const storageProvider = createStorageProvider();
const controller = new AccountController(userService, storageProvider);
const upload = multer({
  dest: ensureDirectory(getTempDir()),
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

/**
 * @openapi
 * /account:
 *   get:
 *     summary: Retorna a conta do usuario autenticado
 *     tags: [Conta]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Conta retornada com sucesso
 *       401:
 *         description: Token ausente ou invalido
 */
router.get('/', authMiddleware, controller.getCurrent);
router.patch('/notification-preferences', authMiddleware, controller.updateNotificationPreferences);

/**
 * @openapi
 * /account/avatar:
 *   post:
 *     summary: Atualiza a foto de perfil do usuário autenticado
 *     tags: [Conta]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Conta atualizada com a URL assinada da foto
 *       400:
 *         description: Arquivo ausente ou tipo inválido
 */
router.post('/avatar', authMiddleware, upload.single('file'), controller.uploadAvatar);

export default router;

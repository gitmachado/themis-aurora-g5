import { Router } from 'express';
import { AccountController } from '../../controllers/implementations/account.controller';
import { UserRepository } from '@repositories';
import { UserService } from '@services';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();

const userRepository = new UserRepository();
const userService = new UserService(userRepository);
const controller = new AccountController(userService);

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

export default router;

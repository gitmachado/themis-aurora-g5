import { Router } from 'express';
import { NotificationController } from '../../controllers/implementations/notification.controller';
import { NotificationService } from '@services';
import { NotificationRepository } from '@repositories';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();

const notificationRepository = new NotificationRepository();
const notificationService = new NotificationService(notificationRepository);
const controller = new NotificationController(notificationService);

/**
 * @openapi
 * /notifications/my:
 *   get:
 *     summary: Lista notificações do usuário logado
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de notificações
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Notification'
 */
router.get('/my', authMiddleware, controller.listMyNotifications);

/**
 * @openapi
 * /notifications/read-all:
 *   post:
 *     summary: Marca todas as notificações do usuário como lidas
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Notificações marcadas como lidas
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: 'string' }
 */
router.post('/read-all', authMiddleware, controller.markAllAsRead);

/**
 * @openapi
 * /notifications/{id}/read:
 *   patch:
 *     summary: Marca uma notificação específica como lida
 *     tags: [Notificações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Notificação atualizada
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Notification'
 *       404:
 *         description: Notificação não encontrada
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.patch('/:id/read', authMiddleware, controller.markAsRead);

export default router;

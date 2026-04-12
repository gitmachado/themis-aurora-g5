import { Router } from 'express';
import { MessageController } from '../../controllers/implementations/message.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';

import { syncMessageSchema } from '../../types/dtos/schemas';

const router = Router();
const controller = new MessageController();

/**
 * @openapi
 * /messages/{whatsappNumber}:
 *   get:
 *     summary: Obtém histórico de mensagens por número de WhatsApp
 *     tags: [Mensagens]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: whatsappNumber
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Histórico de mensagens
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Message'
 */
router.get('/:whatsappNumber', authMiddleware, controller.getByWhatsapp);

/**
 * @openapi
 * /messages/sync:
 *   post:
 *     summary: Sincroniza mensagens recebidas via WhatsApp (Integração Bot)
 *     tags: [Mensagens]
 *     security:
 *       - apiKeyAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/MessageSyncRequest'
 *     responses:
 *       201:
 *         description: Mensagem sincronizada
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Message'
 *       400:
 *         description: Erro de validação
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       401:
 *         description: Não autorizado (API Key inválida)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/sync', apiKeyMiddleware, validate(syncMessageSchema), controller.sync);

export default router;

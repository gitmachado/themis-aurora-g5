import { Router } from 'express';
import { BotController } from '../../controllers/implementations/bot.controller';
import { UserService, LegalProcessService, NotificationService } from '@services';
import { ConfigurationService } from '../../services/implementations/configuration.service';
import {
  UserRepository,
  LegalProcessRepository,
  NotificationRepository,
  TimelineEventRepository,
} from '@repositories';
import { ConfigurationRepository } from '../../repositories/implementations/configuration.repository';
import { TimelineService } from '../../services/implementations/timeline.service';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';

const router = Router();

// Repositories
const userRepository = new UserRepository();
const legalProcessRepository = new LegalProcessRepository();
const timelineRepository = new TimelineEventRepository();
const notificationRepository = new NotificationRepository();
const configurationRepository = new ConfigurationRepository();

// Services
const userService = new UserService(userRepository);
const timelineService = new TimelineService(timelineRepository);
const notificationService = new NotificationService(notificationRepository);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);
const configurationService = new ConfigurationService(configurationRepository);

const controller = new BotController(
  userService,
  legalProcessService,
  configurationService,
  notificationService,
);

// ────────────────────────────────────────────────────
// All routes below are protected by API Key middleware
// ────────────────────────────────────────────────────

/**
 * @openapi
 * /bot/users/by-phone/{whatsappNumber}:
 *   get:
 *     summary: Verifica se um número de WhatsApp pertence a um usuário cadastrado
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     parameters:
 *       - in: path
 *         name: whatsappNumber
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Resultado da busca
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 exists: { type: boolean }
 *                 userId: { type: string }
 *                 name: { type: string }
 */
router.get('/users/by-phone/:whatsappNumber', apiKeyMiddleware, controller.getUserByPhone);

/**
 * @openapi
 * /bot/processes/by-phone/{whatsappNumber}:
 *   get:
 *     summary: Lista processos de um cliente pelo número de WhatsApp
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     parameters:
 *       - in: path
 *         name: whatsappNumber
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de processos do cliente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 processes:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id: { type: string }
 *                       title: { type: string }
 *                       caseType: { type: string }
 *                       processNumber: { type: string }
 *                       status: { type: string }
 *                       lastUpdate: { type: string }
 *                       lawyerNote: { type: string }
 */
router.get('/processes/by-phone/:whatsappNumber', apiKeyMiddleware, controller.getProcessesByPhone);

/**
 * @openapi
 * /bot/configurations:
 *   get:
 *     summary: Retorna configurações do escritório (tom de voz, horários, mensagem de ausência)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     responses:
 *       200:
 *         description: Configurações do escritório
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 toneOfVoice: { type: string }
 *                 serviceHoursStart: { type: string }
 *                 serviceHoursEnd: { type: string }
 *                 awayMessage: { type: string }
 */
router.get('/configurations', apiKeyMiddleware, controller.getConfiguration);

/**
 * @openapi
 * /bot/notifications:
 *   post:
 *     summary: Cria notificação de handoff para o advogado (via Bot)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [type, message, whatsappNumber]
 *             properties:
 *               type: { type: string, example: HANDOFF }
 *               message: { type: string, example: Cliente Maria da Silva solicita atendimento humano. }
 *               whatsappNumber: { type: string, example: '5511999999999' }
 *     responses:
 *       201:
 *         description: Notificação criada
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Notification'
 *       400:
 *         description: Campos obrigatórios faltando
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/notifications', apiKeyMiddleware, controller.createBotNotification);

export default router;

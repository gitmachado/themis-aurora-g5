import { Router } from 'express';
import { LeadController } from '../../controllers/implementations/lead.controller';
import { LeadService, AuthService, NotificationService, LegalProcessService, TimelineService } from '@services';
import {
  LeadRepository,
  UserRepository,
  NotificationRepository,
  LegalProcessRepository,
  TimelineEventRepository,
} from '@repositories';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { createLeadSchema } from '../../types/dtos/schemas';

const router = Router();

const leadRepository = new LeadRepository();
const userRepository = new UserRepository();
const authService = new AuthService(userRepository);
const notificationRepository = new NotificationRepository();
const notificationService = new NotificationService(notificationRepository);
const legalProcessRepository = new LegalProcessRepository();
const timelineRepository = new TimelineEventRepository();
const timelineService = new TimelineService(timelineRepository);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);
const leadService = new LeadService(
  leadRepository,
  userRepository,
  authService,
  notificationService,
  legalProcessService
);

const controller = new LeadController(leadService);

/**
 * @openapi
 * /leads:
 *   get:
 *     summary: Lista todos os leads (Apenas Advogado)
 *     tags: [Leads]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de leads retornada com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Lead'
 *       403:
 *         description: Acesso negado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/', authMiddleware, roleMiddleware(['LAWYER']), controller.listAll);

router.get('/pending', authMiddleware, roleMiddleware(['LAWYER']), controller.listPending);

/**
 * @openapi
 * /leads/{id}:
 *   get:
 *     summary: Obtém detalhes de um lead por ID
 *     tags: [Leads]
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
 *         description: Detalhes do lead
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Lead'
 *       404:
 *         description: Lead não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', authMiddleware, roleMiddleware(['LAWYER']), controller.getById);

/**
 * @openapi
 * /leads:
 *   post:
 *     summary: Cria um novo lead (Integração Bot/WhatsApp)
 *     tags: [Leads]
 *     security:
 *       - apiKeyAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LeadCreateRequest'
 *     responses:
 *       201:
 *         description: Lead criado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Lead'
 *       400:
 *         description: Erro de validação
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 */
router.post('/', apiKeyMiddleware, validate(createLeadSchema), controller.create);

/**
 * @openapi
 * /leads/{id}/convert:
 *   patch:
 *     summary: Converte um lead em cliente (Cria usuário e processo)
 *     tags: [Leads]
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
 *         description: Lead convertido com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: 'string' }
 *                 processId: { type: 'string' }
 *       404:
 *         description: Lead não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', authMiddleware, roleMiddleware(['LAWYER']), controller.delete);
router.patch('/:id', authMiddleware, roleMiddleware(['LAWYER']), controller.update);
router.patch('/:id/convert', authMiddleware, roleMiddleware(['LAWYER']), controller.convert);

router.patch('/:id/discard', authMiddleware, roleMiddleware(['LAWYER']), controller.discard);

router.post('/handoff-return', authMiddleware, roleMiddleware(['LAWYER']), controller.resumeAI);
router.get('/whatsapp/:whatsappNumber', controller.getByWhatsapp);
router.post('/handoff-start', authMiddleware, roleMiddleware(['LAWYER']), controller.startHandoff);
router.post('/:id/assign', authMiddleware, roleMiddleware(['LAWYER']), controller.assign);
router.post('/:id/release', authMiddleware, roleMiddleware(['LAWYER']), controller.release);

export default router;

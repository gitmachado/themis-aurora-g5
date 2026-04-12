import { Router } from 'express';
import { TimelineController } from '../../controllers/implementations/timeline.controller';
import { TimelineService, LegalProcessService, NotificationService } from '@services';
import { TimelineEventRepository, LegalProcessRepository, NotificationRepository } from '@repositories';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();

// Wiring dependencies
const timelineRepository = new TimelineEventRepository();
const timelineService = new TimelineService(timelineRepository);

const legalProcessRepository = new LegalProcessRepository();
const notificationRepository = new NotificationRepository();
const notificationService = new NotificationService(notificationRepository);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);

const controller = new TimelineController(timelineService, legalProcessService);

/**
 * @openapi
 * /timeline/process/{processId}:
 *   get:
 *     summary: Lista os eventos da timeline de um processo
 *     tags: [Timeline]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: processId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de eventos da timeline
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/TimelineEvent'
 *       404:
 *         description: Processo não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/process/:processId', authMiddleware, controller.listByProcess);

export default router;

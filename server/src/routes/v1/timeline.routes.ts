import { Router } from 'express';
import { TimelineController } from '../../controllers/implementations/timeline.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();
const controller = new TimelineController();

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

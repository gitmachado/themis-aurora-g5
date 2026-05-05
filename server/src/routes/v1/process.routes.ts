import { Router } from 'express';
import { LegalProcessController } from '../../controllers/implementations/legal-process.controller';
import { LegalProcessService, TimelineService, NotificationService } from '@services';
import { LegalProcessRepository, TimelineEventRepository, NotificationRepository } from '@repositories';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { updateProcessStatusSchema } from '../../types/dtos/schemas';

const router = Router();

const legalProcessRepository = new LegalProcessRepository();
const timelineRepository = new TimelineEventRepository();
const timelineService = new TimelineService(timelineRepository);
const notificationRepository = new NotificationRepository();
const notificationService = new NotificationService(notificationRepository);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);

const controller = new LegalProcessController(legalProcessService);

/**
 * @openapi
 * /processes/my:
 *   get:
 *     summary: Lista processos do usuário logado (Cliente ou Advogado)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de processos
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/LegalProcess'
 */
router.get('/my', authMiddleware, controller.listMyProcesses);

/**
 * @openapi
 * /processes/{id}:
 *   get:
 *     summary: Obtém detalhes de um processo por ID
 *     tags: [Processos]
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
 *         description: Detalhes do processo
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LegalProcess'
 *       403:
 *         description: Acesso proibido (não é dono do processo)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Processo não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', authMiddleware, controller.getById);

/**
 * @openapi
 * /processes/{id}/status:
 *   patch:
 *     summary: Atualiza o status de um processo (Apenas Advogado responsável)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ProcessStatusUpdateRequest'
 *     responses:
 *       200:
 *         description: Status atualizado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LegalProcess'
 *       400:
 *         description: Erro de validação
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       403:
 *         description: Acesso negado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.patch('/:id/status', authMiddleware, roleMiddleware(['LAWYER']), validate(updateProcessStatusSchema), controller.updateStatus);

/**
 * @openapi
 * /processes/{id}/note:
 *   post:
 *     summary: Adiciona uma nota ao processo (Apenas Advogado responsável)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [note]
 *             properties:
 *               note:
 *                 type: string
 *     responses:
 *       204:
 *         description: Nota adicionada com sucesso
 *       403:
 *         description: Acesso negado
 */
router.post('/:id/note', authMiddleware, roleMiddleware(['LAWYER']), controller.addNote);

/**
 * @openapi
 * /processes/{id}/request-document:
 *   post:
 *     summary: Solicita um documento ao cliente (Apenas Advogado responsável)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [documentName]
 *             properties:
 *               documentName:
 *                 type: string
 *     responses:
 *       204:
 *         description: Documento solicitado com sucesso
 *       403:
 *         description: Acesso negado
 */
router.post('/:id/request-document', authMiddleware, roleMiddleware(['LAWYER']), controller.requestDocument);

/**
 * @openapi
 * /processes/{id}/schedule-event:
 *   post:
 *     summary: Agenda um evento no processo (Apenas Advogado responsável)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, date]
 *             properties:
 *               title:
 *                 type: string
 *               date:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       204:
 *         description: Evento agendado com sucesso
 *       403:
 *         description: Acesso negado
 */
router.post('/:id/schedule-event', authMiddleware, roleMiddleware(['LAWYER']), controller.scheduleEvent);

export default router;

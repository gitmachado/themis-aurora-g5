import { Router } from 'express';
import { AppointmentController } from '../../controllers/implementations/appointment.controller';
import { AppointmentService } from '../../services/implementations/appointment.service';
import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import { TimelineService } from '../../services/implementations/timeline.service';
import { TimelineEventRepository } from '../../repositories/implementations/timeline-event.repository';
import { NotificationService } from '../../services/implementations/notification.service';
import { NotificationRepository } from '../../repositories/implementations/notification.repository';
import { UserRepository } from '../../repositories/implementations/user.repository';
import { PushNotificationService } from '../../services/notifications/push_notification_service';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import {
  createAppointmentSchema,
  updateAppointmentSchema,
  checkConflictsSchema,
  getAvailableSlotsSchema,
} from '../../types/dtos/schemas';

const router = Router();

const appointmentRepository = new AppointmentRepository();
const timelineEventRepository = new TimelineEventRepository();
const notificationRepository = new NotificationRepository();
const userRepository = new UserRepository();
const pushNotificationService = new PushNotificationService();

const timelineService = new TimelineService(timelineEventRepository);
const notificationService = new NotificationService(
  notificationRepository,
  userRepository,
  pushNotificationService
);
const appointmentService = new AppointmentService(
  appointmentRepository,
  timelineService,
  notificationService
);
const controller = new AppointmentController(appointmentService);

/**
 * @openapi
 * /appointments:
 *   post:
 *     summary: Criar novo compromisso na agenda
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateAppointmentRequest'
 *     responses:
 *       201:
 *         description: Compromisso criado com sucesso
 *       400:
 *         description: Dados inválidos
 *       409:
 *         description: Conflito de horário
 */
router.post(
  '/',
  authMiddleware,
  validate(createAppointmentSchema),
  controller.create.bind(controller)
);

/**
 * @openapi
 * /appointments:
 *   get:
 *     summary: Listar compromissos
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: startDate
 *         in: query
 *         schema:
 *           type: string
 *           format: date-time
 *       - name: endDate
 *         in: query
 *         schema:
 *           type: string
 *           format: date-time
 *       - name: type
 *         in: query
 *         schema:
 *           type: string
 *           enum: [MEETING, DEADLINE, HEARING, OTHER]
 *       - name: status
 *         in: query
 *         schema:
 *           type: string
 *           enum: [SCHEDULED, COMPLETED, CANCELED]
 *     responses:
 *       200:
 *         description: Lista de compromissos
 */
router.get('/', authMiddleware, controller.list.bind(controller));

/**
 * @openapi
 * /appointments/{id}:
 *   get:
 *     summary: Obter compromisso por ID
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Compromisso encontrado
 *       404:
 *         description: Compromisso não encontrado
 */
router.get('/:id', authMiddleware, controller.getById.bind(controller));

/**
 * @openapi
 * /appointments/{id}:
 *   patch:
 *     summary: Atualizar compromisso
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateAppointmentRequest'
 *     responses:
 *       200:
 *         description: Compromisso atualizado
 */
router.patch(
  '/:id',
  authMiddleware,
  validate(updateAppointmentSchema),
  controller.update.bind(controller)
);

/**
 * @openapi
 * /appointments/{id}:
 *   delete:
 *     summary: Deletar compromisso
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Compromisso deletado
 */
router.delete('/:id', authMiddleware, controller.delete.bind(controller));

/**
 * @openapi
 * /appointments/check-conflicts:
 *   post:
 *     summary: Verificar conflitos de horário
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CheckConflictsRequest'
 *     responses:
 *       200:
 *         description: Lista de conflitos encontrados
 */
router.post(
  '/conflicts',
  authMiddleware,
  validate(checkConflictsSchema),
  controller.checkConflicts.bind(controller)
);

/**
 * @openapi
 * /appointments/slots:
 *   get:
 *     summary: Obter horários disponíveis em um dia
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: date
 *         in: query
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *       - name: slotDurationMinutes
 *         in: query
 *         schema:
 *           type: integer
 *           default: 60
 *       - name: lawyerId
 *         in: query
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de horários disponíveis
 */
router.get(
  '/slots',
  authMiddleware,
  controller.getAvailableSlots.bind(controller)
);

/**
 * @openapi
 * /appointments/by-process/{processId}:
 *   get:
 *     summary: Obter compromissos de um processo
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: processId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de compromissos do processo
 */
router.get('/by-process/:processId', authMiddleware, controller.getByProcessId.bind(controller));

export default router;

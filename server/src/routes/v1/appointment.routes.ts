import { Router } from 'express';
import { AppointmentController } from '../../controllers/implementations/appointment.controller';
import { AppointmentApprovalController } from '../../controllers/implementations/appointment-approval.controller';
import { RescheduleController } from '../../controllers/implementations/reschedule.controller';
import { AppointmentService } from '../../services/implementations/appointment.service';
import { AppointmentApprovalService } from '../../services/implementations/appointment-approval.service';
import { AppointmentRepository } from '../../repositories/implementations/appointment.repository';
import { RescheduleSuggestionRepository } from '../../repositories/implementations/reschedule-suggestion.repository';
import { RescheduleProcessorService } from '../../services/implementations/reschedule-processor-service';
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
  approveAppointmentSchema,
  rejectAppointmentSchema,
  resetAppointmentSchema,
  requestRescheduleSchema,
  acceptRescheduleSchema,
  rejectRescheduleSchema,
} from '../../types/dtos/schemas';

const router = Router();

const appointmentRepository = new AppointmentRepository();
const rescheduleSuggestionRepository = new RescheduleSuggestionRepository();
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
const appointmentApprovalService = new AppointmentApprovalService(
  appointmentRepository,
  rescheduleSuggestionRepository,
  timelineService,
  notificationService
);
const controller = new AppointmentController(appointmentService);
const approvalController = new AppointmentApprovalController(appointmentApprovalService);
const rescheduleService = new RescheduleProcessorService();
const rescheduleController = new RescheduleController(rescheduleService);

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
 * /appointments/pending:
 *   get:
 *     summary: Listar compromissos pendentes de aprovação
 *     tags: [Agenda - Aprovação]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de compromissos pendentes
 */
router.get('/pending', authMiddleware, approvalController.getPendingApprovals.bind(approvalController));

/**
 * @openapi
 * /appointments/slots:
 *   get:
 *     summary: Obter horários disponíveis em um dia
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
 */
router.get(
  '/slots',
  authMiddleware,
  controller.getAvailableSlots.bind(controller)
);

router.get('/by-process/:processId', authMiddleware, controller.getByProcessId.bind(controller));

/**
 * @openapi
 * /appointments/{id}:
 *   get:
 *     summary: Obter compromisso por ID
 *     tags: [Agenda]
 *     security:
 *       - BearerAuth: []
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
 * /appointments/{id}/approve:
 *   patch:
 *     summary: Aprovar um compromisso pendente
 *     tags: [Agenda - Aprovação]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ApproveAppointmentRequest'
 *     responses:
 *       200:
 *         description: Compromisso aprovado com sucesso
 */
router.patch(
  '/:id/approve',
  authMiddleware,
  validate(approveAppointmentSchema),
  approvalController.approveAppointment.bind(approvalController)
);

/**
 * @openapi
 * /appointments/{id}/reject:
 *   patch:
 *     summary: Rejeitar um compromisso pendente
 *     tags: [Agenda - Aprovação]
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
 *         description: Compromisso rejeitado com sucesso
 */
router.patch(
  '/:id/reject',
  authMiddleware,
  validate(rejectAppointmentSchema),
  approvalController.rejectAppointment.bind(approvalController)
);

/**
 * @openapi
 * /appointments/{id}/reset-to-ai-version:
 *   patch:
 *     summary: Resetar compromisso para versão original da IA
 *     tags: [Agenda - Aprovação]
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
 *         description: Compromisso resetado com sucesso
 */
router.patch(
  '/:id/reset-to-ai-version',
  authMiddleware,
  validate(resetAppointmentSchema),
  approvalController.resetToAIVersion.bind(approvalController)
);

/**
 * @openapi
 * /appointments/{id}/reschedule-request:
 *   post:
 *     summary: Solicitar reagendamento pela IA
 *     tags: [Agenda - Aprovação]
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
 *             $ref: '#/components/schemas/RequestRescheduleSchema'
 *     responses:
 *       201:
 *         description: Solicitação de reagendamento criada
 */
router.post(
  '/:id/reschedule-request',
  authMiddleware,
  validate(requestRescheduleSchema),
  approvalController.requestReschedule.bind(approvalController)
);

/**
 * @openapi
 * /appointments/{id}/reschedule-suggestions:
 *   get:
 *     summary: Obter sugestões de reagendamento
 *     tags: [Agenda - Aprovação]
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
 *         description: Lista de sugestões pendentes
 */
router.get(
  '/:id/reschedule-suggestions',
  authMiddleware,
  approvalController.getRescheduleSuggestions.bind(approvalController)
);

/**
 * @openapi
 * /reschedule-suggestions/{suggestionId}/accept:
 *   patch:
 *     summary: Aceitar sugestão de reagendamento
 *     tags: [Agenda - Aprovação]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: suggestionId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *       - name: appointmentId
 *         in: query
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Sugestão aceita com sucesso
 */
router.patch(
  '/reschedule-suggestions/:suggestionId/accept',
  authMiddleware,
  validate(acceptRescheduleSchema),
  approvalController.acceptReschedule.bind(approvalController)
);

/**
 * @openapi
 * /reschedule-suggestions/{suggestionId}/reject:
 *   patch:
 *     summary: Rejeitar sugestão de reagendamento
 *     tags: [Agenda - Aprovação]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: suggestionId
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Sugestão rejeitada com sucesso
 */
router.patch(
  '/reschedule-suggestions/:suggestionId/reject',
  authMiddleware,
  validate(rejectRescheduleSchema),
  approvalController.rejectReschedule.bind(approvalController)
);

export default router;

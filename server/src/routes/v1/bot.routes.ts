import { Router, Request, Response, NextFunction } from 'express';
import { BotController } from '../../controllers/implementations/bot.controller';
import { UserService, LegalProcessService, NotificationService } from '@services';
import { AppointmentService } from '../../services/implementations/appointment.service';
import { ConfigurationService } from '../../services/implementations/configuration.service';
import { PushNotificationService } from '../../services/notifications/push_notification_service';
import {
  UserRepository,
  LegalProcessRepository,
  NotificationRepository,
  TimelineEventRepository,
  LeadRepository,
  AppointmentRepository,
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
const leadRepository = new LeadRepository();
const appointmentRepository = new AppointmentRepository();

// Services
const userService = new UserService(userRepository);
const timelineService = new TimelineService(timelineRepository);
const pushNotificationService = new PushNotificationService();
const notificationService = new NotificationService(notificationRepository, userRepository, pushNotificationService);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);
const configurationService = new ConfigurationService(configurationRepository);
const appointmentService = new AppointmentService(appointmentRepository, timelineService, notificationService);

const controller = new BotController(
  userService,
  legalProcessService,
  configurationService,
  notificationService,
  leadRepository,
  timelineService,
  appointmentService,
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
 * /bot/users/by-cpf/{cpf}:
 *   get:
 *     summary: Verifica se um CPF pertence a um usuário cadastrado
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     parameters:
 *       - in: path
 *         name: cpf
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
router.get('/users/by-cpf/:cpf', apiKeyMiddleware, controller.getUserByCpf);

/**
 * @openapi
 * /bot/leads/by-phone/{whatsappNumber}:
 *   get:
 *     summary: Verifica se um número de WhatsApp tem lead pendente
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
 *         description: Resultado da busca de lead
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 exists: { type: boolean }
 *                 id: { type: string }
 *                 status: { type: string }
 *                 name: { type: string }
 */
router.get('/leads/by-phone/:whatsappNumber', apiKeyMiddleware, controller.getLeadByPhone);

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

/**
 * @openapi
 * /bot/handoff/start:
 *   post:
 *     summary: Inicia o handoff no banco de dados (AI para Humano)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/handoff/start', apiKeyMiddleware, controller.startHandoff);

/**
 * @openapi
 * /bot/handoff/resume:
 *   post:
 *     summary: Finaliza o handoff no banco de dados (Humano para AI)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/handoff/resume', apiKeyMiddleware, controller.resumeAI);

/**
 * @openapi
 * /bot/appointments/slots:
 *   get:
 *     summary: Consulta horários disponíveis de um advogado (uso exclusivo do Bot)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     parameters:
 *       - name: lawyerId
 *         in: query
 *         required: true
 *         schema: { type: string }
 *       - name: date
 *         in: query
 *         required: true
 *         schema: { type: string, format: date }
 *       - name: slotDurationMinutes
 *         in: query
 *         schema: { type: integer, default: 15 }
 */
router.get('/appointments/slots', apiKeyMiddleware, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { lawyerId, date, slotDurationMinutes } = req.query;
    if (!lawyerId || !date) {
      return res.status(400).json({ error: 'lawyerId and date are required' });
    }
    const slots = await appointmentService.getAvailableSlots(
      lawyerId as string,
      new Date(date as string),
      slotDurationMinutes ? parseInt(slotDurationMinutes as string) : 30
    );
    return res.status(200).json({
      slots: slots.map(s => ({
        time: s.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', timeZone: 'America/Sao_Paulo' }),
        isoTime: s.toISOString(),
      })),
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @openapi
 * /bot/appointments/by-phone/{whatsappNumber}:
 *   get:
 *     summary: Lista agendamentos abertos (não concluídos/cancelados) por número de WhatsApp
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
 *         description: Lista de agendamentos abertos
 */
router.get('/appointments/by-phone/:whatsappNumber', apiKeyMiddleware, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const whatsappNumber = Array.isArray(req.params.whatsappNumber)
      ? req.params.whatsappNumber[0]
      : req.params.whatsappNumber;
    if (!whatsappNumber) {
      return res.status(400).json({ error: 'whatsappNumber is required' });
    }

    // Get all appointments for this phone number where status is not COMPLETED or CANCELED
    const appointments = await appointmentRepository.findByClientWhatsapp(whatsappNumber);
    const openAppointments = appointments.filter(
      a => a.status !== 'COMPLETED' && a.status !== 'CANCELED'
    );

    return res.status(200).json({
      hasOpenAppointments: openAppointments.length > 0,
      count: openAppointments.length,
      appointments: openAppointments.map(a => ({
        id: a.id,
        title: a.title,
        scheduledAt: a.scheduledAt,
        status: a.status,
        type: a.type,
      })),
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @openapi
 * /bot/appointments:
 *   post:
 *     summary: Cria um agendamento pelo Bot (uso exclusivo da IA)
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/appointments', apiKeyMiddleware, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { lawyerId, clientId, title, description, type, scheduledAt, durationMinutes, createdByAI, clientName, clientWhatsappNumber } = req.body;
    if (!lawyerId || !title || !scheduledAt) {
      return res.status(400).json({ error: 'lawyerId, title, and scheduledAt are required' });
    }
    const appointment = await appointmentService.create({
      clientId: clientId || null,
      title,
      description: description || '',
      type: type || 'MEETING',
      scheduledAt,
      durationMinutes: durationMinutes || 30,
      createdByAI: createdByAI ?? true,
      clientName: clientName || null,
      clientWhatsappNumber: clientWhatsappNumber || null,
    }, lawyerId);
    return res.status(201).json(appointment);
  } catch (error) {
    next(error);
  }
});

/**
 * @openapi
 * /bot/process/{id}/status:
 *   patch:
 *     summary: AI-driven status change for a process (validates lawyer ownership server-side).
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [newStatus, lawyerId]
 *             properties:
 *               newStatus: { type: string }
 *               lawyerId: { type: string }
 *               lawyerNote: { type: string, nullable: true }
 */
router.patch('/process/:id/status', apiKeyMiddleware, controller.updateProcessStatus);

/**
 * @openapi
 * /bot/process/{id}/note:
 *   post:
 *     summary: AI adds a note to a process the lawyer owns.
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/process/:id/note', apiKeyMiddleware, controller.addProcessNote);

/**
 * @openapi
 * /bot/process/{id}/request-document:
 *   post:
 *     summary: AI requests a document from the process client.
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/process/:id/request-document', apiKeyMiddleware, controller.requestProcessDocument);

/**
 * @openapi
 * /bot/process/{id}/schedule-event:
 *   post:
 *     summary: AI schedules an event in the process timeline.
 *     tags: [Bot Integration]
 *     security:
 *       - apiKeyAuth: []
 */
router.post('/process/:id/schedule-event', apiKeyMiddleware, controller.scheduleProcessEvent);

export default router;

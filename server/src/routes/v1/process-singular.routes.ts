import { Router, Request, Response, NextFunction } from 'express';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';
import { LegalProcessService, TimelineService, NotificationService } from '@services';
import { LegalProcessRepository, TimelineEventRepository, NotificationRepository, UserRepository } from '@repositories';
import { PushNotificationService } from '../../services/notifications/push_notification_service';

const router = Router();

const legalProcessRepository = new LegalProcessRepository();
const timelineRepository = new TimelineEventRepository();
const timelineService = new TimelineService(timelineRepository);
const notificationRepository = new NotificationRepository();
const userRepository = new UserRepository();
const pushNotificationService = new PushNotificationService();
const notificationService = new NotificationService(notificationRepository, userRepository, pushNotificationService);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);

// GET /process?lawyerId=...
router.get('/', apiKeyMiddleware, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const lawyerId = req.query.lawyerId as string;
    if (!lawyerId || typeof lawyerId !== 'string') {
      res.status(400).json({ error: 'Parâmetro lawyerId é obrigatório' });
      return;
    }

    const processes = await legalProcessService.getByLawyerId(lawyerId);
    res.status(200).json(processes);
  } catch (error) {
    next(error);
  }
});

// GET /process/:id
router.get('/:id', apiKeyMiddleware, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = req.params.id as string;
    const process = await legalProcessService.getById(id);
    if (!process) {
      res.status(404).json({ error: 'Processo não encontrado' });
      return;
    }

    // Load client info
    const clientUser = await userRepository.findById(process.clientId);
    
    // Load timeline events
    const events = await timelineService.getByLegalProcess(id);
    const recentTimeline = events
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .map(e => ({
        data: e.createdAt.toISOString(),
        descricao: e.content,
      }));

    res.status(200).json({
      id: process.id,
      status: process.currentStatus,
      cliente: clientUser ? { nome: clientUser.name, email: clientUser.email } : null,
      recentTimeline,
    });
  } catch (error) {
    next(error);
  }
});

export default router;

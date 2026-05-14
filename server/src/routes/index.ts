import { Router } from 'express';
import authRoutes from './v1/auth.routes';
import accountRoutes from './v1/account.routes';
import clientRoutes from './v1/client.routes';
import leadRoutes from './v1/lead.routes';
import processRoutes from './v1/process.routes';
import processSingularRoutes from './v1/process-singular.routes';
import documentRoutes from './v1/document.routes';
import messageRoutes from './v1/message.routes';
import notificationRoutes from './v1/notification.routes';
import timelineRoutes from './v1/timeline.routes';
import botRoutes from './v1/bot.routes';
import teamRoutes from './v1/team.routes';
import aiRoutes from './v1/ai.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/account', accountRoutes);
router.use('/clients', clientRoutes);
router.use('/leads', leadRoutes);
router.use('/processes', processRoutes);
router.use('/process', processSingularRoutes);
router.use('/documents', documentRoutes);
router.use('/messages', messageRoutes);
router.use('/notifications', notificationRoutes);
router.use('/timeline', timelineRoutes);
router.use('/bot', botRoutes);
router.use('/team', teamRoutes);
router.use('/ai', aiRoutes);

export default router;

import { Router } from 'express';
import authRoutes from './v1/auth.routes';
import leadRoutes from './v1/lead.routes';
import processRoutes from './v1/process.routes';
import documentRoutes from './v1/document.routes';
import messageRoutes from './v1/message.routes';
import notificationRoutes from './v1/notification.routes';
import timelineRoutes from './v1/timeline.routes';
import botRoutes from './v1/bot.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/leads', leadRoutes);
router.use('/processes', processRoutes);
router.use('/documents', documentRoutes);
router.use('/messages', messageRoutes);
router.use('/notifications', notificationRoutes);
router.use('/timeline', timelineRoutes);
router.use('/bot', botRoutes);

export default router;

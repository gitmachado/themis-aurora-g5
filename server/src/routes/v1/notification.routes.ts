import { Router } from 'express';
import { NotificationController } from '../../controllers/notification.controller';
import { authMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const controller = new NotificationController();

router.get('/my', authMiddleware, controller.listMyNotifications);
router.post('/read-all', authMiddleware, controller.markAllAsRead);
router.patch('/:id/read', authMiddleware, controller.markAsRead);

export default router;

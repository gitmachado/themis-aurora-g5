import { Router } from 'express';
import { TimelineController } from '../../controllers/timeline.controller';
import { authMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const controller = new TimelineController();

router.get('/process/:processId', authMiddleware, controller.listByProcess);

export default router;

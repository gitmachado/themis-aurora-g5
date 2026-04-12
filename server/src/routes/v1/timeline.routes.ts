import { Router } from 'express';
import { TimelineController } from '../../controllers/implementations/timeline.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();
const controller = new TimelineController();

router.get('/process/:processId', authMiddleware, controller.listByProcess);

export default router;

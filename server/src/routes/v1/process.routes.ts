import { Router } from 'express';
import { LegalProcessController } from '../../controllers/implementations/legal-process.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { z } from 'zod';

const router = Router();
const controller = new LegalProcessController();

const updateStatusSchema = z.object({
  body: z.object({
    status: z.string().min(1),
    reason: z.string().optional(),
  }),
});

router.get('/my', authMiddleware, controller.listMyProcesses);
router.get('/:id', authMiddleware, controller.getById);
router.patch('/:id/status', authMiddleware, roleMiddleware(['LAWYER']), validate(updateStatusSchema), controller.updateStatus);

export default router;

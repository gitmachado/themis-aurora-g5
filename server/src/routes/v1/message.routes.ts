import { Router } from 'express';
import { MessageController } from '../../controllers/implementations/message.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { z } from 'zod';

const router = Router();
const controller = new MessageController();

const syncMessageSchema = z.object({
  body: z.object({
    whatsappNumber: z.string().min(10),
    content: z.string(),
    senderRole: z.enum(['CLIENT', 'LAWYER', 'BOT']),
    messageType: z.enum(['TEXT', 'IMAGE', 'DOCUMENT']),
  }),
});

router.get('/:whatsappNumber', authMiddleware, controller.getByWhatsapp);
router.post('/sync', apiKeyMiddleware, validate(syncMessageSchema), controller.sync);

export default router;

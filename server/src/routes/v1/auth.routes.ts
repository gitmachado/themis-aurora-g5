import { Router } from 'express';
import { AuthController } from '../../controllers/auth.controller';
import { validate } from '../../middlewares/validationMiddleware';
import { z } from 'zod';

const router = Router();
const controller = new AuthController();

const loginSchema = z.object({
  body: z.object({
    whatsappNumber: z.string().min(10),
    password: z.string().min(6),
  }),
});

const registerSchema = z.object({
  body: z.object({
    name: z.string().min(3),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11),
    password: z.string().min(6),
  }),
});

router.post('/login', validate(loginSchema), controller.login);
router.post('/register', validate(registerSchema), controller.register);

export default router;

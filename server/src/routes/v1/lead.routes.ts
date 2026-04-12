import { Router } from 'express';
import { LeadController } from '../../controllers/implementations/lead.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { apiKeyMiddleware } from '../../middlewares/implementations/apiKeyMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { z } from 'zod';

const router = Router();
const controller = new LeadController();

const createLeadSchema = z.object({
  body: z.object({
    name: z.string().min(3),
    whatsappNumber: z.string().min(10),
    cpf: z.string().length(11),
    caseType: z.enum(['Labor', 'Civil', 'Family', 'Criminal', 'SocialSecurity']),
    description: z.string(),
    urgency: z.enum(['High', 'Medium', 'Low']),
    contactAvailability: z.enum(['Morning', 'Afternoon', 'Evening']),
  }),
});

router.get('/', authMiddleware, roleMiddleware(['LAWYER']), controller.listAll);
router.get('/:id', authMiddleware, roleMiddleware(['LAWYER']), controller.getById);
router.post('/', apiKeyMiddleware, validate(createLeadSchema), controller.create);
router.patch('/:id/convert', authMiddleware, roleMiddleware(['LAWYER']), controller.convert);

export default router;

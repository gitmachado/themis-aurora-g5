import { Router } from 'express';
import { ClientController } from '../../controllers/implementations/client.controller';
import { UserRepository } from '@repositories';
import { UserService } from '@services';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();

const userRepository = new UserRepository();
const userService = new UserService(userRepository);
const controller = new ClientController(userService);

router.get('/my', authMiddleware, controller.listMyClients);
router.get('/:id', authMiddleware, controller.getById);

export default router;

import { Router } from 'express';
import { AuthController } from '../../controllers/implementations/auth.controller';
import { AuthService } from '../../services/implementations/auth.service';
import { UserRepository } from '../../repositories/implementations/user.repository';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import { loginSchema, registerSchema } from '../../types/dtos/schemas';

const router = Router();
const userRepository = new UserRepository();
const authService = new AuthService(userRepository);
const controller = new AuthController(authService);

/**
 * @openapi
 * /auth/login:
 *   post:
 *     summary: Realiza o login do usuário (Cliente ou Advogado)
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *     responses:
 *       200:
 *         description: Login realizado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   $ref: '#/components/schemas/User'
 *                 token:
 *                   type: string
 *       401:
 *         description: Credenciais inválidas
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/login', validate(loginSchema), controller.login);

/**
 * @openapi
 * /auth/register:
 *   post:
 *     summary: Realiza o cadastro de um novo cliente
 *     tags: [Autenticação]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *     responses:
 *       201:
 *         description: Cliente cadastrado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       400:
 *         description: Erro de validação
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 */
router.post('/register', validate(registerSchema), controller.register);

export default router;

import { Router } from 'express';
import { TeamController } from '../../controllers/implementations/team.controller';
import { TeamRepository, UserRepository } from '@repositories';
import { TeamService } from '@services';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';
import {
  createTeamMemberSchema,
  updateTeamPermissionsSchema,
} from '../../types/dtos/schemas';

const router = Router();

const teamRepository = new TeamRepository();
const userRepository = new UserRepository();
const teamService = new TeamService(teamRepository, userRepository);
const controller = new TeamController(teamService);

const adminOnly = roleMiddleware(['LAWYER_ADMIN']);

/**
 * @openapi
 * /team:
 *   get:
 *     summary: Lista os advogados da equipe (apenas Advogado-chefe)
 *     tags: [Equipe]
 *     security:
 *       - bearerAuth: []
 */
router.get('/', authMiddleware, adminOnly, controller.list);

/**
 * @openapi
 * /team/{id}:
 *   get:
 *     summary: Detalhes de um advogado da equipe (apenas Advogado-chefe)
 *     tags: [Equipe]
 *     security:
 *       - bearerAuth: []
 */
router.get('/:id', authMiddleware, adminOnly, controller.getById);

/**
 * @openapi
 * /team:
 *   post:
 *     summary: Adiciona um advogado à equipe (apenas Advogado-chefe)
 *     tags: [Equipe]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateTeamMemberRequest'
 */
router.post(
  '/',
  authMiddleware,
  adminOnly,
  validate(createTeamMemberSchema),
  controller.create
);

/**
 * @openapi
 * /team/{id}/permissions:
 *   patch:
 *     summary: Atualiza as permissões de um advogado (apenas Advogado-chefe)
 *     tags: [Equipe]
 *     security:
 *       - bearerAuth: []
 */
router.patch(
  '/:id/permissions',
  authMiddleware,
  adminOnly,
  validate(updateTeamPermissionsSchema),
  controller.updatePermissions
);

/**
 * @openapi
 * /team/{id}:
 *   delete:
 *     summary: Remove um advogado da equipe (apenas Advogado-chefe)
 *     tags: [Equipe]
 *     security:
 *       - bearerAuth: []
 */
router.delete('/:id', authMiddleware, adminOnly, controller.remove);

export default router;

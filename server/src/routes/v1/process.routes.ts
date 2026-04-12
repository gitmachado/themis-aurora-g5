import { Router } from 'express';
import { LegalProcessController } from '../../controllers/implementations/legal-process.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';
import { roleMiddleware } from '../../middlewares/implementations/roleMiddleware';
import { validate } from '../../middlewares/implementations/validationMiddleware';

import { updateProcessStatusSchema } from '../../types/dtos/schemas';

const router = Router();
const controller = new LegalProcessController();

/**
 * @openapi
 * /processes/my:
 *   get:
 *     summary: Lista processos do usuário logado (Cliente ou Advogado)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de processos
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/LegalProcess'
 */
router.get('/my', authMiddleware, controller.listMyProcesses);

/**
 * @openapi
 * /processes/{id}:
 *   get:
 *     summary: Obtém detalhes de um processo por ID
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Detalhes do processo
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LegalProcess'
 *       403:
 *         description: Acesso proibido (não é dono do processo)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Processo não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', authMiddleware, controller.getById);

/**
 * @openapi
 * /processes/{id}/status:
 *   patch:
 *     summary: Atualiza o status de um processo (Apenas Advogado responsável)
 *     tags: [Processos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ProcessStatusUpdateRequest'
 *     responses:
 *       200:
 *         description: Status atualizado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LegalProcess'
 *       400:
 *         description: Erro de validação
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       403:
 *         description: Acesso negado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.patch('/:id/status', authMiddleware, roleMiddleware(['LAWYER']), validate(updateProcessStatusSchema), controller.updateStatus);

export default router;

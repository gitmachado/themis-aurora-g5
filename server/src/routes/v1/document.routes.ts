import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { DocumentController } from '../../controllers/implementations/document.controller';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();
const controller = new DocumentController();

// Multer configuration for temporary storage
const upload = multer({ 
  dest: path.resolve(__dirname, '../../../../temp'),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

/**
 * @openapi
 * /documents/upload:
 *   post:
 *     summary: Realiza o upload de um documento para um processo
 *     tags: [Documentos]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *               processId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Documento enviado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Document'
 */
router.post('/upload', authMiddleware, upload.single('file'), controller.upload);

/**
 * @openapi
 * /documents/view/{filename}:
 *   get:
 *     summary: Visualiza/Baixa um documento por nome de arquivo
 *     tags: [Documentos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: filename
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Conteúdo do arquivo
 *       404:
 *         description: Arquivo não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/view/:filename', authMiddleware, controller.viewFile);

/**
 * @openapi
 * /documents/process/{processId}:
 *   get:
 *     summary: Lista todos os documentos vinculados a um processo
 *     tags: [Documentos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: processId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de documentos
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Document'
 */
router.get('/process/:processId', authMiddleware, controller.listByProcess);

/**
 * @openapi
 * /documents/{id}:
 *   delete:
 *     summary: Remove um documento por ID
 *     tags: [Documentos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Documento removido
 *       404:
 *         description: Documento não encontrado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', authMiddleware, controller.delete);

export default router;

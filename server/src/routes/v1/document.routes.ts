import { Router } from 'express';
import multer from 'multer';
import { DocumentController } from '../../controllers/implementations/document.controller';
import { DocumentService, LegalProcessService, TimelineService, NotificationService } from '@services';
import { DocumentRepository, LegalProcessRepository, TimelineEventRepository, NotificationRepository, UserRepository } from '@repositories';
import { PushNotificationService } from '../../services/notifications/push_notification_service';
import { createStorageProvider } from '../../utils/storage/storage-provider.factory';
import { ensureDirectory, getTempDir } from '../../utils/storage/storage-paths';
import { authMiddleware } from '../../middlewares/implementations/authMiddleware';

const router = Router();

// Wiring dependencies
const documentRepository = new DocumentRepository();
const documentService = new DocumentService(documentRepository);

const legalProcessRepository = new LegalProcessRepository();
const timelineRepository = new TimelineEventRepository();
const timelineService = new TimelineService(timelineRepository);
const notificationRepository = new NotificationRepository();
const userRepository = new UserRepository();
const pushNotificationService = new PushNotificationService();
const notificationService = new NotificationService(notificationRepository, userRepository, pushNotificationService);
const legalProcessService = new LegalProcessService(
  legalProcessRepository,
  timelineService,
  notificationService
);

const storageProvider = createStorageProvider();

const controller = new DocumentController(
  documentService,
  legalProcessService,
  storageProvider
);

// Multer configuration for temporary storage
const upload = multer({ 
  dest: ensureDirectory(getTempDir()),
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

router.get('/my', authMiddleware, controller.listMyDocuments);

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
 * /documents/{id}/access-url:
 *   get:
 *     summary: Gera uma URL temporária para abrir um documento privado
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
 *       200:
 *         description: URL temporária do arquivo
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 url:
 *                   type: string
 *       404:
 *         description: Documento não encontrado
 */
router.get('/:id/access-url', authMiddleware, controller.getAccessUrl);
router.get('/:id', authMiddleware, controller.getById);

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

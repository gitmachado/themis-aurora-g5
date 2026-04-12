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

router.post('/upload', authMiddleware, upload.single('file'), controller.upload);
router.get('/view/:filename', authMiddleware, controller.viewFile);
router.get('/process/:processId', authMiddleware, controller.listByProcess);
router.delete('/:id', authMiddleware, controller.delete);

export default router;

import { Response, NextFunction, RequestHandler } from 'express';
import fs from 'fs';
import { IDocumentService, ILegalProcessService } from '@services';
import { IStorageProvider } from '../../utils/storage/storage.provider';
import { resolveUploadFilePath } from '../../utils/storage/storage-paths';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ValidationError, ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import { Document, User } from '@models';

type RequestUser = Pick<User, 'id' | 'role'>;

export class DocumentController {
  constructor(
    private readonly documentService: IDocumentService,
    private readonly legalProcessService: ILegalProcessService,
    private readonly storageProvider: IStorageProvider
  ) {}

  upload: RequestHandler<any, Document, { legalProcessId: string }> = async (
    req: AuthRequest<any, Document, { legalProcessId: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const file = (req as any).file;
      if (!file) {
        throw new ValidationError('Nenhum arquivo enviado');
      }

      const legalProcessId = req.body.legalProcessId || (req.body as any).processId;
      if (!legalProcessId) {
        throw new ValidationError('ID do processo é obrigatório');
      }

      const user = req.user!;
      await this.ensureProcessAccess(legalProcessId, user);

      // Validação básica do serviço (tamanho e tipo)
      this.documentService.validateFile(file.size, file.mimetype);

      let fileUrl: string | null = null;
      try {
        fileUrl = await this.storageProvider.saveFile(file, {
          folder: `documents/${legalProcessId}`,
        });
      } catch (error) {
        await this.cleanupTempFile(file);
        throw error;
      }

      try {
        const document = await this.documentService.upload({
          legalProcessId,
          fileName: file.originalname,
          fileUrl,
          mimeType: file.mimetype,
          sizeBytes: file.size,
          sentById: user.id,
        });

        return res.status(201).json(document);
      } catch (error) {
        await this.storageProvider.deleteFile(fileUrl).catch(() => undefined);
        throw error;
      }
    } catch (error) {
      const file = (req as any).file;
      if (file) {
        await this.cleanupTempFile(file);
      }
      next(error);
    }
  };

  listMyDocuments: RequestHandler<any, Document[]> = async (
    req: AuthRequest<any, Document[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const processes = user.role === 'CLIENT'
        ? await this.legalProcessService.getByClientId(user.id)
        : await this.legalProcessService.getByLawyerId(user.id);
      const documents = (
        await Promise.all(
          processes.map((process) => this.documentService.getByLegalProcess(process.id))
        )
      ).flat();

      documents.sort((a, b) => {
        const aTime = new Date(a.createdAt).getTime();
        const bTime = new Date(b.createdAt).getTime();
        return bTime - aTime;
      });

      return res.status(200).json(documents);
    } catch (error) {
      next(error);
    }
  };

  listByProcess: RequestHandler<{ processId: string }, Document[]> = async (
    req: AuthRequest<{ processId: string }, Document[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { processId } = req.params;
      const user = req.user!;

      await this.ensureProcessAccess(processId, user);

      const documents = await this.documentService.getByLegalProcess(processId);
      return res.status(200).json(documents);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, Document> = async (
    req: AuthRequest<{ id: string }, Document>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const document = await this.documentService.getById(req.params.id);
      if (!document) {
        throw new NotFoundError('Documento não encontrado');
      }

      await this.ensureDocumentAccess(document, req.user!);
      return res.status(200).json(document);
    } catch (error) {
      next(error);
    }
  };

  getAccessUrl: RequestHandler<{ id: string }, { url: string }> = async (
    req: AuthRequest<{ id: string }, { url: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const document = await this.documentService.getById(req.params.id);
      if (!document) {
        throw new NotFoundError('Documento não encontrado');
      }

      await this.ensureDocumentAccess(document, req.user!);
      const url = await this.storageProvider.getAccessUrl(document.fileUrl);
      return res.status(200).json({ url });
    } catch (error) {
      next(error);
    }
  };

  viewFile: RequestHandler<{ filename: string }> = async (
    req: AuthRequest<{ filename: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { filename } = req.params;
      const user = req.user!;

      const document = await this.documentService.getByFileName(filename);
      if (!document) {
        throw new NotFoundError('Registro de documento não encontrado');
      }

      await this.ensureDocumentAccess(document, user);

      const url = await this.storageProvider.getAccessUrl(document.fileUrl);
      if (url.startsWith('/uploads/')) {
        const filename = url.split('/').pop();
        if (!filename) {
          throw new NotFoundError('Arquivo físico não encontrado no storage');
        }

        const filePath = resolveUploadFilePath(filename);
        if (!fs.existsSync(filePath)) {
          throw new NotFoundError('Arquivo físico não encontrado no storage');
        }

        return res.sendFile(filePath);
      }

      return res.redirect(url);
    } catch (error) {
      next(error);
    }
  };

  delete: RequestHandler<{ id: string }> = async (
    req: AuthRequest<{ id: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const docId = req.params.id;
      const user = req.user!;

      // 1. RBAC check: Only lawyers can delete documents
      if (user.role !== 'LAWYER' && user.role !== 'LAWYER_ADMIN') {
        throw new ForbiddenError('Apenas advogados podem deletar documentos do sistema');
      }

      // Business logic remains here for now, but using service for data
      const document = await this.documentService.getById(docId);
      if (!document) {
        throw new NotFoundError('Documento não encontrado');
      }

      const process = await this.legalProcessService.getById(document.legalProcessId);
      if (process && process.lawyerId && process.lawyerId !== user.id && user.role !== 'LAWYER_ADMIN') {
        throw new ForbiddenError('Apenas o advogado responsável por este processo pode remover documentos');
      }

      await this.storageProvider.deleteFile(document.fileUrl);
      await this.documentService.delete(docId);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  private async ensureDocumentAccess(document: Document, user: RequestUser): Promise<void> {
    await this.ensureProcessAccess(document.legalProcessId, user);
  }

  private async ensureProcessAccess(processId: string, user: RequestUser): Promise<void> {
    const process = await this.legalProcessService.getById(processId);
    if (!process) {
      throw new NotFoundError('Trâmite não encontrado');
    }

    if (user.role === 'CLIENT' && process.clientId !== user.id) {
      throw new ForbiddenError('Você não tem permissão para acessar documentos deste trâmite');
    }

    if (user.role === 'LAWYER' && process.lawyerId !== user.id) {
      throw new ForbiddenError('Você não tem permissão para acessar documentos deste trâmite');
    }
    // LAWYER_ADMIN tem acesso a todos os processos do escritório.
  }

  private async cleanupTempFile(file: { path?: string }): Promise<void> {
    if (!file.path) return;
    await fs.promises.unlink(file.path).catch(() => undefined);
  }
}

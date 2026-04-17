import { Response, NextFunction, RequestHandler } from 'express';
import fs from 'fs';
import path from 'path';
import { IDocumentService, ILegalProcessService } from '@services';
import { LocalFileStorageProvider } from '../../utils/storage/implementations/local-storage.provider';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ValidationError, ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import { Document } from '@models';

export class DocumentController {
  constructor(
    private readonly documentService: IDocumentService,
    private readonly legalProcessService: ILegalProcessService,
    private readonly storageProvider: LocalFileStorageProvider
  ) {}

  upload: RequestHandler<any, Document, { legalProcessId: string }> = async (
    req: AuthRequest<any, Document, { legalProcessId: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      if (!req.file) {
        throw new ValidationError('Nenhum arquivo enviado');
      }

      const { legalProcessId } = req.body;
      if (!legalProcessId) {
        throw new ValidationError('ID do processo é obrigatório');
      }

      const user = req.user!;

      // Ownership check: If user is a Client, check if they own the process
      if (user.role === 'CLIENT') {
        const process = await this.legalProcessService.getById(legalProcessId);
        if (!process || process.clientId !== user.id) {
          throw new ForbiddenError('Você não tem permissão para enviar documentos para este processo');
        }
      }

      // Validação básica do serviço (tamanho e tipo)
      this.documentService.validateFile(req.file.size, req.file.mimetype);

      // Salva no storage (pasta local por enquanto)
      const fileUrl = await this.storageProvider.saveFile(req.file);

      // Salva metadados no banco
      const document = await this.documentService.upload({
        legalProcessId,
        fileName: req.file.originalname,
        fileUrl,
        mimeType: req.file.mimetype,
        sizeBytes: req.file.size,
        sentById: user.id,
      });

      return res.status(201).json(document);
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

      // Check process ownership if user is a Client
      if (user.role === 'CLIENT') {
        const process = await this.legalProcessService.getById(processId);
        if (!process || process.clientId !== user.id) {
          throw new ForbiddenError('Você não tem permissão para acessar os documentos deste processo');
        }
      }

      const documents = await this.documentService.getByLegalProcess(processId);
      return res.status(200).json(documents);
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

      // 1. Encontrar metadados do documento pelo nome do arquivo
      // For viewFile, we temporarily use repository through service or need a service method.
      // Refinement: Add getByFileName to DocumentService if not present.
      const documents = await this.documentService.getByFileName(filename);
      if (!documents) {
        throw new NotFoundError('Registro de documento não encontrado');
      }

      // 2. Se for cliente, validar se o processo pertence a ele
      if (user.role === 'CLIENT') {
        const process = await this.legalProcessService.getById(documents.legalProcessId);
        if (!process || process.clientId !== user.id) {
          throw new ForbiddenError('Acesso negado a este documento');
        }
      }

      // 3. Verificar arquivo físico
      const filePath = path.resolve(__dirname, '../../../../../uploads', filename);
      if (!fs.existsSync(filePath)) {
        throw new NotFoundError('Arquivo físico não encontrado no storage');
      }

      return res.sendFile(filePath);
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
      if (user.role !== 'LAWYER') {
        throw new ForbiddenError('Apenas advogados podem deletar documentos do sistema');
      }

      // Business logic remains here for now, but using service for data
      const document = await this.documentService.getById(docId);
      if (!document) {
        throw new NotFoundError('Documento não encontrado');
      }

      const process = await this.legalProcessService.getById(document.legalProcessId);
      if (process && process.lawyerId && process.lawyerId !== user.id) {
        throw new ForbiddenError('Apenas o advogado responsável por este processo pode remover documentos');
      }

      await this.documentService.delete(docId);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

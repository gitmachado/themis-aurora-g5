import { Response, NextFunction, RequestHandler } from 'express';
import { ILegalProcessService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import { LegalProcess } from '@models';
import { LegalProcessStatus } from '@enums';

export class LegalProcessController {
  constructor(private readonly legalProcessService: ILegalProcessService) {}

  listMyProcesses: RequestHandler<any, LegalProcess[]> = async (
    req: AuthRequest<any, LegalProcess[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const processes = (user.role === 'LAWYER' || user.role === 'LAWYER_ADMIN')
        ? await this.legalProcessService.getByLawyerId(user.id)
        : await this.legalProcessService.getByClientId(user.id);
      return res.status(200).json(processes);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, LegalProcess> = async (
    req: AuthRequest<{ id: string }, LegalProcess>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const processId = req.params.id;
      const user = req.user!;
      
      const process = await this.legalProcessService.getById(processId);
      
      if (!process) {
        throw new NotFoundError('Processo não encontrado');
      }

      // Ownership check for Clients
      if (user.role === 'CLIENT' && process.clientId !== user.id) {
        throw new ForbiddenError('Você não tem permissão para visualizar este processo');
      }

      if (user.role === 'LAWYER' && process.lawyerId && process.lawyerId !== user.id) {
        throw new ForbiddenError('Você não tem permissão para visualizar este processo');
      }

      return res.status(200).json(process);
    } catch (error) {
      next(error);
    }
  };

  updateStatus: RequestHandler<
    { id: string },
    LegalProcess,
    { status: LegalProcessStatus; reason?: string }
  > = async (
    req: AuthRequest<
      { id: string },
      LegalProcess,
      { status: LegalProcessStatus; reason?: string }
    >,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const processId = req.params.id;
      const user = req.user!;

      const updatedProcess = await this.legalProcessService.updateStatus({
        legalProcessId: processId,
        newStatus: req.body.status,
        lawyerNote: req.body.reason,
        updatedById: user.id
      });
      return res.status(200).json(updatedProcess);
    } catch (error) {
      next(error);
    }
  };

  addNote: RequestHandler<
    { id: string },
    void,
    { note: string }
  > = async (
    req: AuthRequest<
      { id: string },
      void,
      { note: string }
    >,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const processId = req.params.id;
      const user = req.user!;
      const { note } = req.body;

      await this.legalProcessService.addNote(processId, note, user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  requestDocument: RequestHandler<
    { id: string },
    void,
    { documentName: string }
  > = async (
    req: AuthRequest<
      { id: string },
      void,
      { documentName: string }
    >,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const processId = req.params.id;
      const user = req.user!;
      const { documentName } = req.body;

      await this.legalProcessService.requestDocument(processId, documentName, user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  scheduleEvent: RequestHandler<
    { id: string },
    void,
    { title: string; date: string }
  > = async (
    req: AuthRequest<
      { id: string },
      void,
      { title: string; date: string }
    >,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const processId = req.params.id;
      const user = req.user!;
      const { title, date } = req.body;

      await this.legalProcessService.scheduleEvent(processId, title, new Date(date), user.id);
      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  create: RequestHandler<any, LegalProcess, any> = async (
    req: AuthRequest<any, LegalProcess, any>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const process = await this.legalProcessService.create({
        ...req.body,
        lawyerId: user.id
      });
      return res.status(201).json(process);
    } catch (error) {
      next(error);
    }
  };
}


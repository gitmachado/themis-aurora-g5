import { Response, NextFunction, RequestHandler } from 'express';
import { LegalProcessService, TimelineService, NotificationService } from '@services';
import { LegalProcessRepository, TimelineEventRepository, NotificationRepository } from '@repositories';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';

export class LegalProcessController {
  private legalProcessService: LegalProcessService;
  private legalProcessRepository: LegalProcessRepository;

  constructor() {
    this.legalProcessRepository = new LegalProcessRepository();
    const timelineRepository = new TimelineEventRepository();
    const timelineService = new TimelineService(timelineRepository);
    const notificationRepository = new NotificationRepository();
    const notificationService = new NotificationService(notificationRepository);

    this.legalProcessService = new LegalProcessService(
      this.legalProcessRepository,
      timelineService,
      notificationService
    );
  }

  listMyProcesses: RequestHandler = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user!.id;
      const processes = await this.legalProcessService.getByClientId(userId);
      return res.status(200).json(processes);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const processId = req.params.id as string;
      const user = req.user!;
      
      const process = await this.legalProcessService.getById(processId);
      
      if (!process) {
        throw new NotFoundError('Processo não encontrado');
      }

      // Ownership check for Clients
      if (user.role === 'CLIENT' && process.clientId !== user.id) {
        throw new ForbiddenError('Você não tem permissão para visualizar este processo');
      }

      return res.status(200).json(process);
    } catch (error) {
      next(error);
    }
  };

  updateStatus: RequestHandler = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const processId = req.params.id as string;
      const user = req.user!;

      // Refinement: Check if the lawyer is the tutor
      const process = await this.legalProcessRepository.findById(processId);
      if (!process) {
        throw new NotFoundError('Processo não encontrado');
      }

      if (process.lawyerId && process.lawyerId !== user.id) {
        throw new ForbiddenError('Apenas o advogado responsável por este processo pode alterar seu status');
      }

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
}

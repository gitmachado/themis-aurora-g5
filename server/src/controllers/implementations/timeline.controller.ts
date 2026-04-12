import { Response, NextFunction } from 'express';
import { TimelineService } from '@services';
import { TimelineEventRepository, LegalProcessRepository } from '@repositories';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';

export class TimelineController {
  private timelineService: TimelineService;
  private legalProcessRepository: LegalProcessRepository;

  constructor() {
    const repository = new TimelineEventRepository();
    this.legalProcessRepository = new LegalProcessRepository();
    this.timelineService = new TimelineService(repository);
  }

  listByProcess = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const processId = req.params.processId as string;
      const user = req.user!;

      // Ownership check: If client, check if they own the process
      if (user.role === 'CLIENT') {
        const process = await this.legalProcessRepository.findById(processId);
        if (!process || process.clientId !== user.id) {
          throw new ForbiddenError('Você não tem permissão para visualizar o histórico deste processo');
        }
      }

      const events = await this.timelineService.getByLegalProcess(processId);
      return res.status(200).json(events);
    } catch (error) {
      next(error);
    }
  };
}

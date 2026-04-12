import { Response, NextFunction, RequestHandler } from 'express';
import { ITimelineService, ILegalProcessService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError } from '../../services/implementations/errors';
import { TimelineEvent } from '@models';

export class TimelineController {
  constructor(
    private readonly timelineService: ITimelineService,
    private readonly legalProcessService: ILegalProcessService
  ) {}

  listByProcess: RequestHandler<{ processId: string }, TimelineEvent[]> = async (
    req: AuthRequest<{ processId: string }, TimelineEvent[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { processId } = req.params;
      const user = req.user!;

      // Ownership check: If client, check if they own the process
      if (user.role === 'CLIENT') {
        const process = await this.legalProcessService.getById(processId);
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

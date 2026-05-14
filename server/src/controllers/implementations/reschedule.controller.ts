import { Response, NextFunction, RequestHandler } from 'express';
import { RescheduleProcessorService } from '../../services/implementations/reschedule-processor-service';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError } from '../../services/implementations/errors';

export class RescheduleController {
  constructor(private readonly rescheduleService: RescheduleProcessorService) {}

  initiateReschedule: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem solicitar reagendamento');
      }

      const { instruction } = req.body as { instruction: string };

      const result = await this.rescheduleService.initiateReschedule(
        req.params.id,
        user.id,
        instruction
      );

      return res.status(202).json(result);
    } catch (error) {
      next(error);
    }
  };

  getSuggestions: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem visualizar sugestões');
      }

      const suggestions = await this.rescheduleService.getSuggestionsForAppointment(
        req.params.id,
        user.id
      );

      return res.status(200).json({
        count: suggestions.length,
        items: suggestions,
      });
    } catch (error) {
      next(error);
    }
  };
}

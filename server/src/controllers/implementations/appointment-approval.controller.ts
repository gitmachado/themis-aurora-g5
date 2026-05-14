import { Response, NextFunction, RequestHandler } from 'express';
import { AppointmentApprovalService } from '../../services/implementations/appointment-approval.service';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import type { Appointment } from '@models';
import type { UpdateAppointmentDTO } from '@dtos';

export class AppointmentApprovalController {
  constructor(private readonly appointmentApprovalService: AppointmentApprovalService) {}

  getPendingApprovals: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem visualizar compromissos pendentes de aprovação');
      }

      const appointments = await this.appointmentApprovalService.getPendingApprovals(user.id);
      return res.status(200).json({
        count: appointments.length,
        items: appointments
      });
    } catch (error) {
      next(error);
    }
  };

  approveAppointment: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem aprovar compromissos');
      }

      const appointment = await this.appointmentApprovalService.approveAppointment(
        req.params.id,
        user.id,
        req.body
      );

      return res.status(200).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  rejectAppointment: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem rejeitar compromissos');
      }

      await this.appointmentApprovalService.rejectAppointment(req.params.id, user.id);

      return res.status(200).json({ message: 'Compromisso rejeitado com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  resetToAIVersion: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem resetar compromissos');
      }

      const appointment = await this.appointmentApprovalService.resetToAIVersion(req.params.id, user.id);

      return res.status(200).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  requestReschedule: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem solicitar reagendamento');
      }

      const suggestion = await this.appointmentApprovalService.requestReschedule(
        req.params.id,
        user.id,
        req.body.instruction
      );

      return res.status(201).json(suggestion);
    } catch (error) {
      next(error);
    }
  };

  getRescheduleSuggestions: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem visualizar sugestões de reagendamento');
      }

      const suggestions = await this.appointmentApprovalService.getRescheduleSuggestions(
        req.params.id,
        user.id
      );

      return res.status(200).json({
        count: suggestions.length,
        items: suggestions
      });
    } catch (error) {
      next(error);
    }
  };

  acceptReschedule: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const { appointmentId } = req.query as { appointmentId: string };

      if (!appointmentId) {
        throw new Error('appointmentId is required as query parameter');
      }

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem aceitar sugestões');
      }

      const appointment = await this.appointmentApprovalService.acceptReschedule(
        req.params.suggestionId,
        appointmentId,
        user.id
      );

      return res.status(200).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  rejectReschedule: RequestHandler = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem rejeitar sugestões');
      }

      await this.appointmentApprovalService.rejectReschedule(req.params.suggestionId, user.id);

      return res.status(200).json({ message: 'Sugestão rejeitada com sucesso' });
    } catch (error) {
      next(error);
    }
  };
}

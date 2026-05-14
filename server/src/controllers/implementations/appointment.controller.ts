import { Response, NextFunction, RequestHandler } from 'express';
import { IAppointmentService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import type { Appointment } from '@models';
import type { CreateAppointmentDTO, UpdateAppointmentDTO, AppointmentResponseDTO } from '@dtos';

export class AppointmentController {
  constructor(private readonly appointmentService: IAppointmentService) {}

  create: RequestHandler<any, Appointment, CreateAppointmentDTO> = async (
    req: AuthRequest<any, Appointment, CreateAppointmentDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem criar compromissos');
      }

      const lawyerId = user.id;

      if (user.role === 'LAWYER' && lawyerId !== user.id) {
        throw new ForbiddenError('Você não pode criar compromissos para outro advogado');
      }

      const appointment = await this.appointmentService.create(req.body, lawyerId);
      return res.status(201).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  list: RequestHandler<any, Appointment[]> = async (
    req: AuthRequest<any, Appointment[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const { startDate, endDate, type, status } = req.query;

      let appointments: Appointment[] = [];

      if (user.role === 'CLIENT') {
        appointments = await this.appointmentService.getByClientId(user.id);
      } else {
        const start = startDate ? new Date(startDate as string) : undefined;
        const end = endDate ? new Date(endDate as string) : undefined;
        appointments = await this.appointmentService.getByLawyerId(user.id, start, end);
      }

      if (type) {
        appointments = appointments.filter(a => a.type === type);
      }

      if (status) {
        appointments = appointments.filter(a => a.status === status);
      }

      return res.status(200).json(appointments);
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, Appointment> = async (
    req: AuthRequest<{ id: string }, Appointment>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const appointment = await this.appointmentService.getById(req.params.id);

      if (!appointment) {
        throw new NotFoundError('Compromisso não encontrado');
      }

      if (
        user.role === 'CLIENT' &&
        appointment.clientId !== user.id
      ) {
        throw new ForbiddenError('Acesso negado a este compromisso');
      }

      if (
        (user.role === 'LAWYER' || user.role === 'LAWYER_ADMIN') &&
        appointment.lawyerId !== user.id
      ) {
        throw new ForbiddenError('Acesso negado a este compromisso');
      }

      return res.status(200).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  update: RequestHandler<{ id: string }, Appointment, UpdateAppointmentDTO> = async (
    req: AuthRequest<{ id: string }, Appointment, UpdateAppointmentDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem modificar compromissos');
      }

      const appointment = await this.appointmentService.update(
        req.params.id,
        req.body,
        user.id
      );

      return res.status(200).json(appointment);
    } catch (error) {
      next(error);
    }
  };

  delete: RequestHandler<{ id: string }, { message: string }> = async (
    req: AuthRequest<{ id: string }, { message: string }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem deletar compromissos');
      }

      await this.appointmentService.delete(req.params.id, user.id);
      return res.status(200).json({ message: 'Compromisso deletado com sucesso' });
    } catch (error) {
      next(error);
    }
  };

  checkConflicts: RequestHandler<
    any,
    Appointment[],
    { scheduledAt: Date; durationMinutes: number }
  > = async (
    req: AuthRequest<any, Appointment[], { scheduledAt: Date; durationMinutes: number }>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;

      if (user.role === 'CLIENT') {
        throw new ForbiddenError('Clientes não podem verificar disponibilidade');
      }

      const { scheduledAt, durationMinutes } = req.body;
      const conflicts = await this.appointmentService.checkConflicts(
        user.id,
        new Date(scheduledAt),
        durationMinutes
      );

      return res.status(200).json(conflicts);
    } catch (error) {
      next(error);
    }
  };

  getAvailableSlots: RequestHandler<any, Date[]> = async (
    req: AuthRequest<any, Date[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user!;
      const { date, slotDurationMinutes } = req.query;

      if (!date) {
        return res.status(400).json({ error: 'date parameter is required' });
      }

      const lawyerId = (req.query.lawyerId as string) || user.id;

      if (
        user.role === 'LAWYER' &&
        lawyerId !== user.id
      ) {
        throw new ForbiddenError('Você só pode verificar sua própria agenda');
      }

      const slots = await this.appointmentService.getAvailableSlots(
        lawyerId,
        new Date(date as string),
        slotDurationMinutes ? parseInt(slotDurationMinutes as string) : 60
      );

      return res.status(200).json(slots);
    } catch (error) {
      next(error);
    }
  };

  getByProcessId: RequestHandler<{ processId: string }, Appointment[]> = async (
    req: AuthRequest<{ processId: string }, Appointment[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const appointments = await this.appointmentService.getByProcessId(req.params.processId);
      return res.status(200).json(appointments);
    } catch (error) {
      next(error);
    }
  };
}

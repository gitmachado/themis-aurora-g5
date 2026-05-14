import { Response, NextFunction, RequestHandler } from 'express';
import { IUserService } from '@services';
import { AuthRequest } from '../../middlewares/implementations/authMiddleware';
import { ForbiddenError, NotFoundError } from '../../services/implementations/errors';
import { UserResponseDTO } from '@dtos';

export class ClientController {
  constructor(private readonly userService: IUserService) {}

  listMyClients: RequestHandler<any, UserResponseDTO[]> = async (
    req: AuthRequest<any, UserResponseDTO[]>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      if (req.user!.role !== 'LAWYER' && req.user!.role !== 'LAWYER_ADMIN') {
        throw new ForbiddenError('Apenas advogados podem listar clientes');
      }

      const clients = await this.userService.getClientsByLawyerId(req.user!.id);

      return res.status(200).json(
        clients.map((client) => ({
          id: client.id,
          name: client.name,
          whatsappNumber: client.whatsappNumber,
          cpf: client.cpf,
          email: client.email,
          role: client.role,
        }))
      );
    } catch (error) {
      next(error);
    }
  };

  getById: RequestHandler<{ id: string }, UserResponseDTO> = async (
    req: AuthRequest<{ id: string }, UserResponseDTO>,
    res: Response,
    next: NextFunction
  ) => {
    try {
      if (req.user!.role !== 'LAWYER' && req.user!.role !== 'LAWYER_ADMIN') {
        throw new ForbiddenError('Apenas advogados podem acessar clientes');
      }

      const client = await this.userService.getClientByLawyerId(
        req.user!.id,
        req.params.id
      );
      if (!client) {
        throw new NotFoundError('Cliente não encontrado');
      }

      return res.status(200).json({
        id: client.id,
        name: client.name,
        whatsappNumber: client.whatsappNumber,
        cpf: client.cpf,
        email: client.email,
        role: client.role,
      });
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
      if (req.user!.role !== 'LAWYER' && req.user!.role !== 'LAWYER_ADMIN') {
        throw new ForbiddenError('Apenas advogados podem deletar clientes');
      }

      await this.userService.hardDeleteClient(req.user!.id, req.params.id);

      return res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}

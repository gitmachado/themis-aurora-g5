import { Response, NextFunction } from 'express';
import { AuthRequest } from './authMiddleware';
import { ForbiddenError } from '../../services/implementations/errors';

/**
 * Middleware to check if the user has one of the required roles.
 *
 * Granting `LAWYER` implicitly grants `LAWYER_ADMIN`, since the head lawyer is
 * a superset of a regular lawyer. To restrict to head lawyers only, list
 * `LAWYER_ADMIN` explicitly without `LAWYER`.
 */
export const roleMiddleware = (allowedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      if (!req.user) {
        throw new ForbiddenError('Usuário não autenticado');
      }

      const effective = new Set(allowedRoles);
      if (effective.has('LAWYER')) {
        effective.add('LAWYER_ADMIN');
      }

      if (!effective.has(req.user.role)) {
        throw new ForbiddenError('Você não tem permissão para acessar este recurso');
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

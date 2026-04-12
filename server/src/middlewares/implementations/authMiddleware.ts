import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { UnauthorizedError } from '../../services/implementations/errors';
import { UserRole } from '@enums';

export interface JWTPayload {
  sub: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}

export interface AuthRequest<
  P = any,
  ResBody = any,
  ReqBody = any,
  Query = any
> extends Request<P, ResBody, ReqBody, Query> {
  user?: {
    id: string;
    role: UserRole;
  };
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    throw new UnauthorizedError('Token não fornecido');
  }

  const parts = authHeader.split(' ');

  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    throw new UnauthorizedError('Token malformatado');
  }

  const token = parts[1];
  const secret = process.env.JWT_SECRET || 'super-secret-key-change-me';

  try {
    const decoded = jwt.verify(token, secret) as JWTPayload;
    
    req.user = {
      id: decoded.sub,
      role: decoded.role,
    };

    return next();
  } catch (err) {
    throw new UnauthorizedError('Token inválido ou expirado');
  }
};

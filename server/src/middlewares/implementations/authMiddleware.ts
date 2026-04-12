import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { UnauthorizedError } from '../../services/implementations/errors';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    role: string;
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
    const decoded = jwt.verify(token, secret) as { sub: string; role: string };
    
    req.user = {
      id: decoded.sub,
      role: decoded.role,
    };

    return next();
  } catch (err) {
    throw new UnauthorizedError('Token inválido ou expirado');
  }
};

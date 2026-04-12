import { Request, Response, NextFunction } from 'express';
import { AppError } from '../../services/implementations/errors';

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      status: 'error',
      code: error.errorCode || 'APP_ERROR',
      message: error.message,
    });
  }

  // Log unexpected errors
  console.error('[UnhandledError]:', error);

  return res.status(500).json({
    status: 'error',
    code: 'INTERNAL_SERVER_ERROR',
    message: 'Ocorreu um erro interno no servidor',
  });
};

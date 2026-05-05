import { Request, Response, NextFunction, RequestHandler } from 'express';
import { UnauthorizedError } from '../../services/implementations/errors';
import { getBotApiKey } from '../../config/runtime';

/**
 * Middleware to validate API Key for bot/system integration
 */
export const apiKeyMiddleware: RequestHandler = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  const validKey = getBotApiKey();

  if (!validKey) {
    // In development we keep the local workflow flexible.
    console.warn('WARNING: BOT_API_KEY not configured in .env');
    return next();
  }

  if (apiKey !== validKey) {
    throw new UnauthorizedError('Invalid or missing API Key');
  }

  next();
};

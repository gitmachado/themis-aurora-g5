import { Request, Response, NextFunction, RequestHandler } from 'express';
import { UnauthorizedError } from '../services/implementations/errors';

/**
 * Middleware to validate API Key for bot/system integration
 */
export const apiKeyMiddleware: RequestHandler = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  const validKey = process.env.BOT_API_KEY;

  if (!validKey) {
    // If not configured, we allow (only for local dev if forgotten), 
    // but in production this should be mandatory.
    console.warn('WARNING: BOT_API_KEY not configured in .env');
    return next();
  }

  if (apiKey !== validKey) {
    throw new UnauthorizedError('Invalid or missing API Key');
  }

  next();
};

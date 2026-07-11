import { NextFunction, Request, Response } from 'express';
import { AppError, NotFoundError } from '../utils/AppError';
import { logger } from '../utils/logger';

/**
 * Catch-all handler for unmatched routes. Must be registered after all
 * other routes and before the error handler.
 */
export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  next(new NotFoundError(`Route not found: ${req.method} ${req.originalUrl}`));
}

/**
 * Centralized error handling middleware. Must be registered last, after
 * all routes and the notFoundHandler.
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction): void {
  const appError =
    err instanceof AppError
      ? err
      : new AppError(err instanceof Error ? err.message : 'Internal server error', 500, 'INTERNAL_ERROR');

  if (!appError.isOperational || appError.statusCode >= 500) {
    logger.error(appError.message, { code: appError.code, stack: appError.stack });
  } else {
    logger.warn(appError.message, { code: appError.code });
  }

  res.status(appError.statusCode).json({
    status: 'error',
    error: {
      code: appError.code,
      message: appError.message,
    },
  });
}

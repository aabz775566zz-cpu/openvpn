import { Request, Response } from 'express';
import { config } from '../config';

/**
 * GET /health
 *
 * Lightweight liveness check used by orchestrators, load balancers, and
 * uptime monitoring. Must not depend on the database or any downstream
 * service so it can respond even during partial outages.
 */
export function getHealth(_req: Request, res: Response): void {
  res.status(200).json({
    status: 'ok',
    service: config.serviceName,
  });
}

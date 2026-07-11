import cors from 'cors';
import express, { Application } from 'express';
import helmet from 'helmet';
import { config } from './config';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import healthRoutes from './routes/health.routes';
import v1Router from './routes/v1';

/**
 * Builds and configures the Express application.
 *
 * Kept separate from server.ts so the app can be imported directly in
 * tests (via supertest) without binding to a network port.
 */
export function createApp(): Application {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  app.use(requestLogger);

  // Top-level liveness check, intentionally outside API versioning so
  // orchestrators/load balancers can rely on a stable path.
  app.use(healthRoutes);

  // Versioned API surface for all feature endpoints.
  app.use(config.apiPrefix, v1Router);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

export default createApp;

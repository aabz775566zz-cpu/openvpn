/**
 * Centralized environment configuration.
 *
 * All environment variables consumed by the backend should be read here,
 * validated/defaulted, and re-exported as a typed object so the rest of the
 * codebase never calls `process.env` directly.
 */
import dotenv from 'dotenv';

dotenv.config();

export type NodeEnv = 'development' | 'test' | 'production';

export interface AppConfig {
  env: NodeEnv;
  port: number;
  serviceName: string;
  apiPrefix: string;
  logLevel: string;
  jwt: {
    secret: string;
    expiresInSeconds: number;
  };
}

const nodeEnv = (process.env.NODE_ENV as NodeEnv) || 'development';

const DEV_ONLY_JWT_SECRET = 'dev-only-insecure-secret-do-not-use-in-production';

function resolveJwtSecret(): string {
  const secret = process.env.JWT_SECRET;

  if (secret) {
    return secret;
  }

  if (nodeEnv === 'production') {
    throw new Error('JWT_SECRET must be set in production. Refusing to start with an insecure default.');
  }

  // eslint-disable-next-line no-console
  console.warn(
    '[WARN] JWT_SECRET is not set — falling back to an insecure development-only secret. ' +
      'Set JWT_SECRET in your .env file before deploying to any shared or production environment.',
  );
  return DEV_ONLY_JWT_SECRET;
}

export const config: AppConfig = {
  env: nodeEnv,
  port: Number(process.env.PORT) || 3000,
  serviceName: process.env.SERVICE_NAME || 'OpenWorld VPN Backend',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  logLevel: process.env.LOG_LEVEL || 'info',
  jwt: {
    secret: resolveJwtSecret(),
    expiresInSeconds: Number(process.env.JWT_EXPIRES_IN_SECONDS) || 3600,
  },
};

export default config;

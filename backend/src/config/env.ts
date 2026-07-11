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
}

const nodeEnv = (process.env.NODE_ENV as NodeEnv) || 'development';

export const config: AppConfig = {
  env: nodeEnv,
  port: Number(process.env.PORT) || 3000,
  serviceName: process.env.SERVICE_NAME || 'OpenWorld VPN Backend',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  logLevel: process.env.LOG_LEVEL || 'info',
};

export default config;

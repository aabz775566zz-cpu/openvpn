/**
 * Minimal logging foundation.
 *
 * This provides a single, consistent logging interface for the application.
 * It can be swapped out for a more feature-rich logger (e.g., winston/pino)
 * in a later phase without changing call sites elsewhere in the codebase.
 */
import { config } from '../config';

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LEVEL_WEIGHT: Record<LogLevel, number> = {
  debug: 10,
  info: 20,
  warn: 30,
  error: 40,
};

function shouldLog(level: LogLevel): boolean {
  const configuredLevel = (config.logLevel as LogLevel) in LEVEL_WEIGHT ? (config.logLevel as LogLevel) : 'info';
  return LEVEL_WEIGHT[level] >= LEVEL_WEIGHT[configuredLevel];
}

function format(level: LogLevel, message: string, meta?: unknown): string {
  const timestamp = new Date().toISOString();
  const base = `[${timestamp}] [${level.toUpperCase()}] ${message}`;
  if (meta === undefined) {
    return base;
  }
  try {
    return `${base} ${JSON.stringify(meta)}`;
  } catch {
    return base;
  }
}

export const logger = {
  debug(message: string, meta?: unknown): void {
    if (shouldLog('debug')) {
      // eslint-disable-next-line no-console
      console.debug(format('debug', message, meta));
    }
  },
  info(message: string, meta?: unknown): void {
    if (shouldLog('info')) {
      // eslint-disable-next-line no-console
      console.info(format('info', message, meta));
    }
  },
  warn(message: string, meta?: unknown): void {
    if (shouldLog('warn')) {
      // eslint-disable-next-line no-console
      console.warn(format('warn', message, meta));
    }
  },
  error(message: string, meta?: unknown): void {
    if (shouldLog('error')) {
      // eslint-disable-next-line no-console
      console.error(format('error', message, meta));
    }
  },
};

export default logger;

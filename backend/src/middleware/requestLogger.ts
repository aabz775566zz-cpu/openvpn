import morgan, { StreamOptions } from 'morgan';
import { logger } from '../utils/logger';

const stream: StreamOptions = {
  write: (message: string) => logger.info(message.trim()),
};

/**
 * HTTP request logging middleware, piping morgan's output through the
 * application logger for consistent formatting.
 */
export const requestLogger = morgan('combined', { stream });

export default requestLogger;

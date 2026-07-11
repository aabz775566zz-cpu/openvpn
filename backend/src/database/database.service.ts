/**
 * Database service layer.
 *
 * Wraps the Prisma client lifecycle (connect/disconnect/health check) so
 * the rest of the application depends on this service rather than the raw
 * Prisma client directly. This makes it straightforward to swap the
 * underlying persistence technology or add cross-cutting concerns (e.g.
 * retries, metrics) in one place.
 */
import { prisma } from './prisma';

export class DatabaseService {
  /**
   * Opens the database connection pool.
   *
   * Not called anywhere yet — the backend does not connect to a real
   * database in this phase. Provided for future wiring (e.g. on server
   * startup) once a database is provisioned.
   */
  static async connect(): Promise<void> {
    await prisma.$connect();
  }

  /** Gracefully closes the database connection pool. */
  static async disconnect(): Promise<void> {
    await prisma.$disconnect();
  }

  /**
   * Lightweight connectivity check, intended for future health/readiness
   * endpoints once the database is provisioned.
   */
  static async isHealthy(): Promise<boolean> {
    try {
      await prisma.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }
}

export { prisma };
export default DatabaseService;

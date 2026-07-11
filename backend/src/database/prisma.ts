/**
 * Prisma client singleton.
 *
 * Ensures a single `PrismaClient` instance is reused across the app (and
 * across hot-reloads in development) instead of exhausting database
 * connections by instantiating a new client per import.
 *
 * NOTE: This module does not connect to a real database in this phase.
 * `DATABASE_URL` is a placeholder (see `.env.example`) and no code path in
 * the current backend calls `connect()`/queries against it yet.
 */
import { PrismaClient } from '@prisma/client';

declare global {
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

function createPrismaClient(): PrismaClient {
  return new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
  });
}

// Reuse the client across module reloads in development (ts-node-dev) to
// avoid opening excessive database connections.
export const prisma: PrismaClient = global.__prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== 'production') {
  global.__prisma = prisma;
}

export default prisma;

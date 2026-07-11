/**
 * Connection log repository.
 */
import type { Connection, Prisma } from '@prisma/client';
import { prisma } from '../database';
import { BaseRepository } from './base.repository';

export class ConnectionRepository extends BaseRepository<
  Connection,
  Prisma.ConnectionCreateInput,
  Prisma.ConnectionUpdateInput
> {
  constructor() {
    super(prisma.connection);
  }

  async findByUserId(userId: string): Promise<Connection[]> {
    return prisma.connection.findMany({ where: { userId } });
  }

  async findActiveByUserId(userId: string): Promise<Connection[]> {
    return prisma.connection.findMany({ where: { userId, disconnectedAt: null } });
  }
}

export default ConnectionRepository;

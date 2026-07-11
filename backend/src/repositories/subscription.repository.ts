/**
 * Subscription repository.
 */
import type { Prisma, Subscription } from '@prisma/client';
import { prisma } from '../database';
import { BaseRepository } from './base.repository';

export class SubscriptionRepository extends BaseRepository<
  Subscription,
  Prisma.SubscriptionCreateInput,
  Prisma.SubscriptionUpdateInput
> {
  constructor() {
    super(prisma.subscription);
  }

  async findByUserId(userId: string): Promise<Subscription[]> {
    return prisma.subscription.findMany({ where: { userId } });
  }
}

export default SubscriptionRepository;

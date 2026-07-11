/**
 * VPN server directory repository.
 */
import type { Prisma, VPNServer } from '@prisma/client';
import { prisma } from '../database';
import { BaseRepository } from './base.repository';

export class VPNServerRepository extends BaseRepository<
  VPNServer,
  Prisma.VPNServerCreateInput,
  Prisma.VPNServerUpdateInput
> {
  constructor() {
    super(prisma.vPNServer);
  }

  async findByCountry(country: string): Promise<VPNServer[]> {
    return prisma.vPNServer.findMany({ where: { country } });
  }
}

export default VPNServerRepository;

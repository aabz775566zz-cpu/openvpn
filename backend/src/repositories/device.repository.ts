/**
 * Device repository.
 */
import type { Device, Prisma } from '@prisma/client';
import { prisma } from '../database';
import { BaseRepository } from './base.repository';

export class DeviceRepository extends BaseRepository<
  Device,
  Prisma.DeviceCreateInput,
  Prisma.DeviceUpdateInput
> {
  constructor() {
    super(prisma.device);
  }

  async findByUserId(userId: string): Promise<Device[]> {
    return prisma.device.findMany({ where: { userId } });
  }
}

export default DeviceRepository;

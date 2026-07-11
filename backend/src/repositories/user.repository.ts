/**
 * User repository.
 *
 * Adds user-specific lookups on top of the generic CRUD foundation from
 * `BaseRepository`.
 */
import type { Prisma, User } from '@prisma/client';
import { prisma } from '../database';
import { BaseRepository } from './base.repository';

export class UserRepository extends BaseRepository<
  User,
  Prisma.UserCreateInput,
  Prisma.UserUpdateInput
> {
  constructor() {
    super(prisma.user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } });
  }

  async findByUsername(username: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { username } });
  }
}

export default UserRepository;

/**
 * Repository pattern foundation.
 *
 * Defines a minimal generic CRUD contract that concrete repositories
 * implement on top of a Prisma delegate. This keeps data-access logic
 * isolated from controllers/services, and makes it possible to swap or
 * mock the persistence layer in tests without touching business logic.
 */

/** Generic CRUD contract implemented by all repositories. */
export interface Repository<TModel, TCreateInput, TUpdateInput, TId = string> {
  findById(id: TId): Promise<TModel | null>;
  findMany(): Promise<TModel[]>;
  create(data: TCreateInput): Promise<TModel>;
  update(id: TId, data: TUpdateInput): Promise<TModel>;
  delete(id: TId): Promise<TModel>;
}

/**
 * Base repository implementing the common CRUD operations against a
 * Prisma model delegate (e.g. `prisma.user`). Concrete repositories extend
 * this class and add entity-specific query methods.
 */
export abstract class BaseRepository<
  TModel,
  TCreateInput,
  TUpdateInput,
  TId = string,
> implements Repository<TModel, TCreateInput, TUpdateInput, TId>
{
  protected constructor(protected readonly delegate: PrismaDelegate<TModel, TCreateInput, TUpdateInput, TId>) {}

  async findById(id: TId): Promise<TModel | null> {
    return this.delegate.findUnique({ where: { id } });
  }

  async findMany(): Promise<TModel[]> {
    return this.delegate.findMany();
  }

  async create(data: TCreateInput): Promise<TModel> {
    return this.delegate.create({ data });
  }

  async update(id: TId, data: TUpdateInput): Promise<TModel> {
    return this.delegate.update({ where: { id }, data });
  }

  async delete(id: TId): Promise<TModel> {
    return this.delegate.delete({ where: { id } });
  }
}

/**
 * Minimal shape of a Prisma model delegate that `BaseRepository` depends
 * on. Using a narrow structural type (rather than importing every
 * generated Prisma delegate type) keeps this foundation agnostic of the
 * specific model it is instantiated for.
 */
export interface PrismaDelegate<TModel, TCreateInput, TUpdateInput, TId> {
  findUnique(args: { where: { id: TId } }): Promise<TModel | null>;
  findMany(args?: Record<string, never>): Promise<TModel[]>;
  create(args: { data: TCreateInput }): Promise<TModel>;
  update(args: { where: { id: TId }; data: TUpdateInput }): Promise<TModel>;
  delete(args: { where: { id: TId } }): Promise<TModel>;
}

# Database Design

> This document defines the data model and storage strategy for OpenWorld
> VPN. Phase 1 captured the conceptual design; Phase 2 (this revision)
> introduces the concrete Prisma schema and repository foundation under
> `backend/`. **No real database is connected yet** — `DATABASE_URL` is a
> placeholder, no migrations have been applied, and no authentication
> providers or VPN connection logic are implemented.

## 1. Storage Technology

- **Engine**: PostgreSQL.
- **ORM**: [Prisma](https://www.prisma.io/) (`prisma` CLI + `@prisma/client`),
  chosen for its type-safe generated client, first-class TypeScript
  support, and built-in migration tooling.
- Schema source of truth: `backend/prisma/schema.prisma`.
- Migrations live under `backend/prisma/migrations/` (structure only —
  no migrations have been generated/applied against a real database yet).
- Legacy/cross-cutting schema notes and seed data continue to live under
  `database/` at the repository root; the executable Prisma schema lives
  in `backend/prisma/`.

## 2. Backend Database Layer

```
backend/
├── prisma/
│   ├── schema.prisma       # Prisma schema: datasource, generator, models
│   └── migrations/         # Migration history (empty — no DB provisioned yet)
│
└── src/
    ├── database/
    │   ├── prisma.ts             # PrismaClient singleton
    │   ├── database.service.ts   # connect/disconnect/health-check wrapper
    │   └── index.ts
    │
    └── repositories/
        ├── base.repository.ts        # Generic Repository<T> contract + BaseRepository
        ├── user.repository.ts
        ├── device.repository.ts
        ├── subscription.repository.ts
        ├── vpnServer.repository.ts
        ├── connection.repository.ts
        └── index.ts
```

- **`DatabaseService`** wraps the Prisma client lifecycle (`connect`,
  `disconnect`, `isHealthy`) so application code depends on this service
  rather than importing the raw Prisma client everywhere.
- **Repository pattern**: `BaseRepository<TModel, TCreateInput, TUpdateInput>`
  implements generic CRUD (`findById`, `findMany`, `create`, `update`,
  `delete`) against a Prisma model delegate. Each entity repository
  extends it and adds entity-specific queries (e.g.
  `UserRepository.findByEmail`). This isolates data-access logic from
  future controllers/services and keeps persistence swappable/mockable in
  tests.

## 3. Concrete Schema (Prisma)

### User (`users`)
| Field        | Type           | Notes                                |
|--------------|----------------|---------------------------------------|
| id           | String (uuid)  | Primary key                           |
| email        | String         | Unique                                |
| username     | String         | Unique                                |
| authProvider | AuthProvider   | Enum: `EMAIL`, `GOOGLE`, `APPLE`      |
| createdAt    | DateTime       | Defaults to now                       |
| updatedAt    | DateTime       | Auto-updated                          |

Relations: has many `Device`, `Subscription`, `Connection`.

### Device (`devices`)
| Field      | Type            | Notes                                        |
|------------|-----------------|-----------------------------------------------|
| id         | String (uuid)   | Primary key                                   |
| userId     | String          | FK → `users.id` (cascade delete)              |
| deviceName | String          |                                                |
| platform   | DevicePlatform  | Enum: `ANDROID`, `IOS`, `WINDOWS`, `MACOS`, `LINUX` |
| createdAt  | DateTime        | Defaults to now                               |

### Subscription (`subscriptions`)
| Field     | Type               | Notes                                     |
|-----------|--------------------|--------------------------------------------|
| id        | String (uuid)      | Primary key                                |
| userId    | String             | FK → `users.id` (cascade delete)           |
| plan      | SubscriptionPlan   | Enum: `FREE`, `MONTHLY`, `YEARLY`          |
| status    | SubscriptionStatus | Enum: `TRIAL`, `ACTIVE`, `EXPIRED`, `CANCELED` |
| startDate | DateTime           | Defaults to now                            |
| endDate   | DateTime?          | Nullable                                   |

### VPNServer (`vpn_servers`)
| Field    | Type          | Notes                                            |
|----------|---------------|----------------------------------------------------|
| id       | String (uuid) | Primary key                                        |
| country  | String        |                                                     |
| city     | String        |                                                     |
| status   | ServerStatus  | Enum: `ACTIVE`, `DEGRADED`, `OFFLINE`, `MAINTENANCE` |
| capacity | Int           | Defaults to 0                                      |

### Connection (`connections`)
| Field          | Type          | Notes                                    |
|----------------|---------------|--------------------------------------------|
| id             | String (uuid) | Primary key                                |
| userId         | String        | FK → `users.id` (cascade delete)           |
| serverId       | String        | FK → `vpn_servers.id` (cascade delete)     |
| deviceId       | String?       | FK → `devices.id` (set null on delete)     |
| connectedAt    | DateTime      | Defaults to now                            |
| disconnectedAt | DateTime?     | Nullable — null while session is active    |

Minimal metadata only — no browsing activity or traffic content is ever
logged, per `SECURITY_GUIDELINES.md`.

## 4. Core Entities (conceptual)

### User
Represents an end-user account.
- Unique identifier
- Email / login identifier
- Authentication credentials (hashed, never stored in plaintext)
- Preferred language (e.g., `en`, `zh`)
- Account status (active, suspended, deleted)
- Timestamps (created, updated)

### Device
Represents a device that has installed the client application.
- Unique identifier
- Owning user reference
- Platform (Android, iOS, Windows, macOS)
- Device public key (for WireGuard peer configuration)
- Last-seen timestamp
- Status (active, revoked)

### Subscription
Represents a user's commercial plan.
- Unique identifier
- Owning user reference
- Plan type / tier
- Status (trial, active, expired, canceled)
- Start / end / renewal dates
- Payment provider reference (external ID only — no card data stored)

### VPN Server
Represents a node in the VPN infrastructure fleet, tracked by the backend
for directory and load-balancing purposes.
- Unique identifier
- Region / location
- Public endpoint (host/port)
- Public key (server-side WireGuard key)
- Capacity / load metrics
- Health status

### Session / Connection Log
Represents connection activity for diagnostics and abuse prevention.
- Unique identifier
- User/device reference
- VPN server reference
- Connected-at / disconnected-at timestamps
- Minimal metadata only — no browsing activity or traffic content is ever
  logged (see `SECURITY_GUIDELINES.md`).

### Admin User
Represents an internal operator with dashboard access.
- Unique identifier
- Login identifier
- Authentication credentials (hashed)
- Role (e.g., support, operations, super-admin)

## 5. Relationships (conceptual)

- A `User` has many `Device`s.
- A `User` has one active `Subscription` at a time (with historical
  records retained).
- A `Device` connects to a `VPN Server`, producing `Session` records.
- An `Admin User` is independent of `User` and has role-based access to
  manage the above entities via the Admin Dashboard.

## 6. Data Protection Principles

- No plaintext secrets, passwords, or private keys are ever persisted.
- Connection/session logs are minimized and retained only as long as
  operationally necessary.
- Personally identifiable information is limited to what is strictly
  required for account and billing functionality.

## 7. Next Steps (Phase 3)

- Provision an actual PostgreSQL instance (dev/staging) and set a real
  `DATABASE_URL`.
- Generate and apply the first `prisma migrate dev` migration.
- Implement authentication providers (email, OAuth) referenced by
  `User.authProvider`.
- Implement VPN connection/session lifecycle logic against the
  `Connection` model.
- Add the `Admin User` model and role-based access for the Admin
  Dashboard.
- Define indexing and partitioning strategy for scale.

# OpenWorld VPN — Backend

This is the backend REST API for OpenWorld VPN, built with **TypeScript**,
**Node.js**, and **Express**. It implements the "control plane" described in
[`../docs/SYSTEM_ARCHITECTURE.md`](../docs/SYSTEM_ARCHITECTURE.md): user
accounts, subscriptions, and the VPN server directory. It never handles
user VPN traffic directly — that is the responsibility of the WireGuard
infrastructure in `../infrastructure/vpn-server/`.

> **Phase 3 scope**: This phase adds the JWT-based authentication
> foundation (`src/auth/`) — a provider abstraction with mocked Google,
> Apple, and WeChat providers, login/logout/me routes, and JWT
> validation middleware. **No real OAuth keys are configured, no external
> identity provider APIs are called**, and payments/VPN connection logic
> remain unimplemented — see
> [`../docs/DEVELOPMENT_ROADMAP.md`](../docs/DEVELOPMENT_ROADMAP.md) for
> what comes next.

## Requirements

- Node.js 18+ (developed against Node.js 22)
- npm 10+

## Getting Started

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

The server starts on `http://localhost:3000` by default (configurable via
`.env`). Verify it's running:

```bash
curl http://localhost:3000/health
# {"status":"ok","service":"OpenWorld VPN Backend"}
```

## Available Scripts

| Script             | Description                                              |
|---------------------|-----------------------------------------------------------|
| `npm run dev`        | Run the server in watch mode with `ts-node-dev`.          |
| `npm run build`      | Compile TypeScript to `dist/` using `tsconfig.build.json`. |
| `npm start`          | Run the compiled server from `dist/` (run `build` first). |
| `npm test`           | Run the Jest + Supertest test suite.                      |
| `npm run test:watch` | Run tests in watch mode.                                   |
| `npm run lint`       | Type-check the whole project (source + tests) with `tsc`. |
| `npm run prisma:generate` | Regenerate the Prisma client from `prisma/schema.prisma`. |
| `npm run prisma:migrate`  | Create/apply a dev migration (requires a real `DATABASE_URL`). |
| `npm run prisma:deploy`   | Apply pending migrations in non-dev environments.       |
| `npm run prisma:studio`   | Launch Prisma Studio (requires a real `DATABASE_URL`).  |

## Environment Configuration

Copy `.env.example` to `.env` and adjust as needed:

| Variable       | Default                    | Description                                   |
|-----------------|------------------------------|------------------------------------------------|
| `PORT`           | `3000`                       | Port the HTTP server listens on.               |
| `NODE_ENV`       | `development`                | Runtime environment.                           |
| `SERVICE_NAME`   | `OpenWorld VPN Backend`      | Returned by the health check endpoint.         |
| `API_PREFIX`     | `/api/v1`                    | Base path for the versioned REST API.          |
| `LOG_LEVEL`      | `info`                       | Minimum log level (`debug`, `info`, `warn`, `error`). |
| `DATABASE_URL`   | placeholder (see `.env.example`) | PostgreSQL connection string used by Prisma. **Not connected to a real database yet** — no code path calls `DatabaseService.connect()`. |
| `JWT_SECRET`     | dev-only fallback (see `src/config/env.ts`) | Secret used to sign/verify session tokens. **Set a real, strong secret in every non-local environment.** |
| `JWT_EXPIRES_IN_SECONDS` | `3600`                | Session token lifetime, in seconds.            |

All environment variables are read and validated in a single place:
`src/config/env.ts`. The rest of the codebase should import `config` from
`src/config` rather than reading `process.env` directly.

## Folder Structure

```
backend/
├── prisma/
│   ├── schema.prisma        # Prisma schema: datasource, generator, models
│   └── migrations/          # Migration history (empty — no DB provisioned yet)
│
├── src/
│   ├── app.ts              # Express app assembly (middleware + routes), importable by tests
│   ├── server.ts           # Entry point: starts the HTTP server
│   ├── config/             # Environment configuration
│   ├── routes/              # Route definitions
│   │   ├── health.routes.ts # GET /health
│   │   └── v1/               # Versioned API router mounted at API_PREFIX (/api/v1)
│   ├── auth/                # JWT authentication: service, controller, routes, providers, middleware
│   ├── controllers/         # Request handlers
│   ├── services/            # Business logic (empty — populated in later phases)
│   ├── database/            # Prisma client singleton + DatabaseService (connect/disconnect/health)
│   ├── repositories/        # Repository pattern: BaseRepository + per-entity repositories
│   ├── middleware/          # Express middleware (error handling, request logging)
│   ├── models/              # Data models (empty — Prisma-generated types are used instead)
│   └── utils/                # Shared utilities (logger, AppError)
│
├── tests/                    # Jest + Supertest test suites
├── .env.example               # Documented environment variable template
├── jest.config.js
├── tsconfig.json               # Base TypeScript config (used for type-checking & tests)
├── tsconfig.build.json          # Build-only config (emits to dist/, excludes tests)
└── package.json
```

## API

### Health Check

```
GET /health
```

Returns `200 OK` with:

```json
{
  "status": "ok",
  "service": "OpenWorld VPN Backend"
}
```

This endpoint is intentionally outside API versioning so it provides a
stable path for load balancers, orchestrators, and uptime monitors.

### Versioned API

All feature endpoints are mounted under the `API_PREFIX` (`/api/v1` by
default) via `src/routes/v1/index.ts`. See [Authentication](#authentication-phase-3)
below for the endpoints implemented so far.

### Error Responses

Unmatched routes and thrown errors are handled centrally by
`src/middleware/errorHandler.ts` and return a consistent JSON shape:

```json
{
  "status": "error",
  "error": {
    "code": "NOT_FOUND",
    "message": "Route not found: GET /unknown"
  }
}
```

## Testing

Tests use **Jest** with **ts-jest** and **Supertest**, exercising the
Express app directly (no network port required):

```bash
npm test
```

## Database Layer (Phase 2)

- **Schema**: `prisma/schema.prisma` defines `User`, `Device`,
  `Subscription`, `VPNServer`, and `Connection` models against PostgreSQL
  (see [`../docs/DATABASE_DESIGN.md`](../docs/DATABASE_DESIGN.md) for the
  full field-level design).
- **Service layer**: `src/database/` exposes a `PrismaClient` singleton
  and a `DatabaseService` wrapper (`connect`/`disconnect`/`isHealthy`).
- **Repositories**: `src/repositories/` implements a generic
  `BaseRepository` CRUD foundation, extended by one repository per entity
  (`UserRepository`, `DeviceRepository`, `SubscriptionRepository`,
  `VPNServerRepository`, `ConnectionRepository`).
- **Not yet connected**: `DATABASE_URL` in `.env.example` is a placeholder;
  no migrations have been generated/applied, and no code path opens a
  real database connection.

## Authentication (Phase 3)

`src/auth/` implements a JWT-based session authentication foundation:

- **Provider abstraction** (`auth.types.ts`): every identity provider
  implements `verifyIdentity(credential)` and `getUserProfile(providerUserId)`.
- **Providers** (`auth/providers/`): `GoogleProvider`, `AppleProvider`,
  `WeChatProvider` — all return **mocked** responses. No real OAuth keys
  are configured and no external API is ever called; credentials are
  validated by prefix (e.g. `mock-google-token-<id>`) only.
- **Service** (`auth.service.ts`): orchestrates login (provider
  verification → JWT issuance), token verification, and logout (in-memory
  token revocation).
- **JWT session payload**: `userId`, `provider`, `issuedAt`, `expiry`.
- **Middleware** (`auth/middleware/auth.middleware.ts`): `requireAuth`
  validates the bearer token and populates `req.auth`; used to protect
  `/auth/logout` and `/auth/me`.
- **Rate limiting**: all `/auth/*` routes are rate-limited per client IP
  (`express-rate-limit`) to mitigate brute-force/credential-stuffing
  attempts against login.
- **Routes** (`auth.routes.ts`), mounted at `${API_PREFIX}/auth`:

  | Method | Path      | Auth required | Description                        |
  |--------|-----------|----------------|--------------------------------------|
  | POST   | `/login`  | No             | Verify a provider credential, issue a JWT. |
  | POST   | `/logout` | Yes            | Revoke the presented session token.  |
  | GET    | `/me`     | Yes            | Return the authenticated user's identity. |

- **Tests** (`tests/auth.test.ts`, `tests/auth.providers.test.ts`): cover
  the valid login → `/me` → logout flow, invalid/expired/forged/missing
  token handling, and provider abstraction consistency.

## Future Modules

The following are intentionally **not** implemented yet and are planned for
subsequent development phases (see
[`../docs/DEVELOPMENT_ROADMAP.md`](../docs/DEVELOPMENT_ROADMAP.md)):

- **Real identity providers** — actual Google/Apple/WeChat OAuth
  integration (real credentials, external API calls) replacing the mocked
  providers above.
- **User persistence on login** — wiring `AuthService.login` to
  `UserRepository` to create/look up a real `User` record instead of
  using the provider's raw id.
- **Provisioned database** — an actual PostgreSQL instance, applied
  migrations, and services/controllers wired to the repositories above.
- **Subscriptions & billing** — plan management and payment integration.
- **VPN server directory & connection logic** — endpoints for issuing
  WireGuard configuration, recording connection sessions, and reporting
  server health, coordinating with `../infrastructure/vpn-server/`.
- **Admin-facing endpoints** — supporting the dashboard in `../apps/admin/`.

See [`../docs/SECURITY_GUIDELINES.md`](../docs/SECURITY_GUIDELINES.md) for
security practices that apply as these modules are built.

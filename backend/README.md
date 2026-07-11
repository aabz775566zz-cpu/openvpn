# OpenWorld VPN — Backend

This is the backend REST API for OpenWorld VPN, built with **TypeScript**,
**Node.js**, and **Express**. It implements the "control plane" described in
[`../docs/SYSTEM_ARCHITECTURE.md`](../docs/SYSTEM_ARCHITECTURE.md): user
accounts, subscriptions, and the VPN server directory. It never handles
user VPN traffic directly — that is the responsibility of the WireGuard
infrastructure in `../infrastructure/vpn-server/`.

> **Phase 1 scope**: This is the foundational scaffold only. Authentication,
> database connectivity, and VPN functionality are **not** implemented yet —
> see [`../docs/DEVELOPMENT_ROADMAP.md`](../docs/DEVELOPMENT_ROADMAP.md) for
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

## Environment Configuration

Copy `.env.example` to `.env` and adjust as needed:

| Variable       | Default                    | Description                                   |
|-----------------|------------------------------|------------------------------------------------|
| `PORT`           | `3000`                       | Port the HTTP server listens on.               |
| `NODE_ENV`       | `development`                | Runtime environment.                           |
| `SERVICE_NAME`   | `OpenWorld VPN Backend`      | Returned by the health check endpoint.         |
| `API_PREFIX`     | `/api/v1`                    | Base path for the versioned REST API.          |
| `LOG_LEVEL`      | `info`                       | Minimum log level (`debug`, `info`, `warn`, `error`). |

All environment variables are read and validated in a single place:
`src/config/env.ts`. The rest of the codebase should import `config` from
`src/config` rather than reading `process.env` directly.

## Folder Structure

```
backend/
├── src/
│   ├── app.ts              # Express app assembly (middleware + routes), importable by tests
│   ├── server.ts           # Entry point: starts the HTTP server
│   ├── config/             # Environment configuration
│   ├── routes/              # Route definitions
│   │   ├── health.routes.ts # GET /health
│   │   └── v1/               # Versioned API router mounted at API_PREFIX (/api/v1)
│   ├── controllers/         # Request handlers
│   ├── services/            # Business logic (empty — populated in later phases)
│   ├── middleware/          # Express middleware (error handling, request logging)
│   ├── models/              # Data models (empty — populated once the database is connected)
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
default) via `src/routes/v1/index.ts`. No feature routes are implemented
yet in Phase 1.

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

## Future Modules

The following are intentionally **not** implemented yet and are planned for
subsequent development phases (see
[`../docs/DEVELOPMENT_ROADMAP.md`](../docs/DEVELOPMENT_ROADMAP.md)):

- **Authentication** — user registration, login, sessions/tokens.
- **Database connectivity** — PostgreSQL integration following
  [`../docs/DATABASE_DESIGN.md`](../docs/DATABASE_DESIGN.md); `models/` and
  `services/` will be populated once this lands.
- **Subscriptions & billing** — plan management and payment integration.
- **VPN server directory** — endpoints for issuing WireGuard configuration
  and reporting server health, coordinating with
  `../infrastructure/vpn-server/`.
- **Admin-facing endpoints** — supporting the dashboard in `../apps/admin/`.

See [`../docs/SECURITY_GUIDELINES.md`](../docs/SECURITY_GUIDELINES.md) for
security practices that apply as these modules are built.

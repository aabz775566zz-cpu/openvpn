# OpenWorld VPN — Backend

Server-side application that powers OpenWorld VPN: the public API, authentication,
subscription management, VPN server management, and data persistence.

## Structure

```
backend/
└── src/
    ├── api/                 # API service (HTTP/gRPC entrypoints, routing, controllers)
    ├── auth/                 # Authentication module (login, tokens, sessions)
    ├── subscription/         # Subscription & billing module
    ├── server-management/    # VPN server fleet management module
    └── database/             # Database layer (models, migrations, repositories)
```

## Module Overview

- **api** — Exposes the HTTP/gRPC endpoints consumed by the mobile app and admin
  dashboard.
- **auth** — Handles user authentication, authorization, and session/token management.
- **subscription** — Manages subscription plans, billing, and entitlements.
- **server-management** — Manages the lifecycle of VPN server nodes (provisioning,
  health checks, capacity).
- **database** — Encapsulates data access: models, migrations, and repositories.

## Status

This is a placeholder scaffold. No real business logic or VPN functionality has been
implemented yet.

## Getting Started (future work)

1. Install [Node.js](https://nodejs.org/) (LTS) or the runtime chosen for this service.
2. Run `npm install` to install dependencies.
3. Copy `.env.example` to `.env` and configure local values.
4. Run `npm run dev` to start the local development server.

## Environment Variables

Copy `.env.example` to `.env` and fill in the values for your local environment. Never
commit real secrets.

# OpenWorld VPN

## Overview

OpenWorld VPN is a scalable, commercial-grade VPN product built for general
users, launching first in the China market with native support for both
English and Chinese. The product spans native client applications, a
TypeScript/Node.js backend, a WireGuard-based VPN infrastructure, and an
admin dashboard for operations.

This repository currently contains the professional project foundation:
folder structure, architecture, and planning documentation. Application
code will be added in subsequent development phases — see
[`docs/DEVELOPMENT_ROADMAP.md`](docs/DEVELOPMENT_ROADMAP.md).

## Architecture Summary

OpenWorld VPN is composed of four independently deployable systems:

1. **Client Application** (`apps/mobile/`) — a Flutter app for Android,
   iOS, Windows, and macOS with built-in English/Chinese localization.
2. **Backend** (`backend/`) — a TypeScript/Node.js REST API handling
   authentication, users, subscriptions, and the VPN server directory.
3. **VPN Infrastructure** (`infrastructure/vpn-server/`) — a WireGuard-based
   data plane, fully decoupled from the backend, responsible only for
   encrypted tunneling and traffic routing.
4. **Admin Dashboard** (`apps/admin/`) — an internal web application for
   managing users, subscriptions, and the VPN server fleet.

See [`docs/SYSTEM_ARCHITECTURE.md`](docs/SYSTEM_ARCHITECTURE.md) for full
details and a diagram of how these components interact.

## Repository Structure

```
/
├── apps/
│   ├── mobile/        # Flutter client application
│   └── admin/          # Admin dashboard web application
│
├── backend/            # TypeScript/Node.js REST API
│
├── infrastructure/
│   └── vpn-server/     # WireGuard-based VPN infrastructure
│
├── database/           # Database schemas, migrations, seed data
│
├── docs/                # Project documentation
│
├── tests/               # Cross-cutting/integration test suites
│
└── .github/
    └── workflows/       # CI/CD pipelines
```

## Development Roadmap

The project is delivered in phases, from foundational setup through China
market launch readiness and beyond. See the full plan in
[`docs/DEVELOPMENT_ROADMAP.md`](docs/DEVELOPMENT_ROADMAP.md):

1. Project Foundation *(current phase)*
2. Backend Foundations
3. VPN Infrastructure Foundations
4. Client Application (MVP)
5. Admin Dashboard (MVP)
6. Subscriptions & Billing
7. China Market Launch Readiness
8. Scale & Expansion

## Technology Stack

| Layer               | Technology                          |
|----------------------|--------------------------------------|
| Client Application    | Flutter (Android, iOS, Windows, macOS) |
| Backend               | TypeScript, Node.js, REST API        |
| VPN Infrastructure    | WireGuard                            |
| Admin Dashboard       | Web application                      |
| Database              | See [`docs/DATABASE_DESIGN.md`](docs/DATABASE_DESIGN.md) |
| CI/CD                 | GitHub Actions (`.github/workflows/`) |

## Documentation

- [`docs/PROJECT_BLUEPRINT.md`](docs/PROJECT_BLUEPRINT.md) — vision, goals, and high-level structure
- [`docs/SYSTEM_ARCHITECTURE.md`](docs/SYSTEM_ARCHITECTURE.md) — detailed technical architecture
- [`docs/DEVELOPMENT_ROADMAP.md`](docs/DEVELOPMENT_ROADMAP.md) — phased delivery plan
- [`docs/DATABASE_DESIGN.md`](docs/DATABASE_DESIGN.md) — data model and storage strategy
- [`docs/SECURITY_GUIDELINES.md`](docs/SECURITY_GUIDELINES.md) — security and compliance guidelines

## Status

This repository currently holds the professional foundation only. No
application code, fake VPN functionality, secrets, or API keys have been
added. The structure is ready for development to begin per the roadmap.
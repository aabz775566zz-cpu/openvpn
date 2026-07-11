# OpenWorld VPN

OpenWorld VPN is a cross-platform VPN service consisting of a mobile client, an admin
dashboard, a backend API, and the supporting infrastructure needed to run and manage
VPN servers at scale.

This repository contains the initial **production project scaffold**. It defines the
folder structure, module boundaries, and placeholder configuration needed before real
feature development begins. No VPN functionality or production secrets are included
at this stage.

## Repository Structure

```
openworld-vpn/
├── apps/
│   ├── mobile/           # Flutter application (end-user VPN client)
│   └── admin/            # Admin dashboard application
│
├── backend/
│   ├── src/api/                  # API service (HTTP/gRPC entrypoints)
│   ├── src/auth/                 # Authentication module
│   ├── src/subscription/         # Subscription / billing module
│   ├── src/server-management/    # VPN server management module
│   └── src/database/             # Database layer (models, migrations, repositories)
│
├── infrastructure/
│   ├── docker/            # Dockerfiles and container configuration
│   ├── deployment/        # Deployment manifests (Kubernetes, Terraform, etc.)
│   └── vpn-server/        # VPN server provisioning and configuration
│
├── docs/                  # Project documentation
├── tests/                 # Cross-cutting and integration tests
└── .github/workflows/     # CI/CD pipelines
```

## Directory Purposes

- **apps/mobile** — The Flutter-based mobile client that end users install to connect
  to the VPN service.
- **apps/admin** — The web-based admin dashboard used by operators to manage users,
  servers, and subscriptions.
- **backend** — The server-side application composed of an API service, authentication,
  subscription management, VPN server management, and the database layer.
- **infrastructure** — Docker, deployment, and VPN server provisioning configuration
  used to build, ship, and run the system.
- **docs** — Architecture, design, and operational documentation for the project.
- **tests** — Test suites that span multiple components (integration/e2e tests). Unit
  tests live alongside their respective app/service.
- **.github/workflows** — Continuous integration and deployment workflow definitions.

## Status

This is an early-stage scaffold. Modules contain placeholder files and configuration
only — no real VPN functionality or production secrets have been implemented yet.

## Next Steps

1. Flesh out the backend API service with a minimal health-check endpoint.
2. Set up the authentication module (e.g., JWT-based auth) with a real database
   connection.
3. Scaffold the Flutter mobile app with a basic UI shell and connect it to the API.
4. Scaffold the admin dashboard with a basic UI shell and authentication flow.
5. Wire up local development with Docker Compose (API + database).
6. Add CI workflows that lint, build, and test each component on every pull request.

# System Architecture

## 1. Overview

OpenWorld VPN is composed of four major systems that are independently
deployable and scalable:

1. **Client Application** (Flutter) — the app end users install.
2. **Backend** (TypeScript/Node.js REST API) — the control plane.
3. **VPN Infrastructure** (WireGuard) — the data plane.
4. **Admin Dashboard** — internal operations tooling.

```
                     ┌─────────────────────┐
                     │   Client Application │
                     │  (Flutter: Android,  │
                     │  iOS, Windows, macOS) │
                     └──────────┬───────────┘
                                │ REST (HTTPS)
                                ▼
                     ┌─────────────────────┐
                     │       Backend        │
                     │ (TypeScript/Node.js) │
                     │  - Auth               │
                     │  - Users              │
                     │  - Subscriptions      │
                     │  - Server directory   │
                     └──────────┬───────────┘
                                │ Provisioning / config API
                                ▼
                     ┌─────────────────────┐
                     │  VPN Infrastructure  │
                     │     (WireGuard)      │
                     │  - Edge servers       │
                     │  - Key management     │
                     └──────────┬───────────┘
                                │ Encrypted tunnel (WireGuard protocol)
                                ▼
                          Public Internet

                     ┌─────────────────────┐
                     │   Admin Dashboard     │
                     │  (Web application)    │
                     └──────────┬───────────┘
                                │ REST (HTTPS, authenticated)
                                ▼
                            Backend
```

## 2. Client Application

- **Framework**: Flutter, enabling a single codebase for Android, iOS,
  Windows, and macOS.
- **Localization**: Built-in multi-language support, launching with English
  and Chinese (Simplified).
- **Responsibilities**:
  - User authentication and account management UI.
  - Displaying available VPN server locations.
  - Establishing and monitoring the WireGuard tunnel.
  - Subscription/billing status display.

## 3. Backend

- **Language/Runtime**: TypeScript on Node.js.
- **API style**: REST.
- **Responsibilities**:
  - User registration, authentication, and session management.
  - Subscription and billing lifecycle.
  - Device registration and management.
  - Serving the list of available VPN servers/regions to clients.
  - Issuing VPN access credentials/configuration (coordinating with the
    VPN infrastructure, but never handling user traffic itself).
- **Design notes**:
  - Stateless API instances behind a load balancer to allow horizontal
    scaling.
  - Clear versioned API contracts (e.g., `/api/v1/...`).

## 4. VPN Infrastructure

- **Protocol**: WireGuard.
- **Deployment**: Deployed and scaled independently from the backend,
  living under `infrastructure/vpn-server/`.
- **Responsibilities**:
  - Terminating encrypted WireGuard tunnels from clients.
  - Routing user traffic to the public internet.
  - Reporting server health/capacity back to the backend for
    directory/load-balancing purposes.
- **Design notes**:
  - Servers are treated as ephemeral, horizontally scalable nodes.
  - No business logic or user data is stored on VPN nodes.

## 5. Admin Dashboard

- **Purpose**: Internal tool for the operations team to manage users,
  subscriptions, VPN server fleets, and monitor system health.
- **Access**: Restricted to authenticated administrators, communicating
  with the backend over authenticated REST calls.

## 6. Database

- Shared persistence layer used by the backend and admin dashboard.
- Detailed schema and technology choice tracked in `DATABASE_DESIGN.md`.

## 7. Cross-Cutting Concerns

- **CI/CD**: Automation pipelines live in `.github/workflows/`.
- **Testing**: Cross-cutting/integration tests live in `tests/`; unit tests
  live alongside their respective app/service.
- **Security**: See `SECURITY_GUIDELINES.md`.

# OpenWorld VPN

**OpenWorld VPN** is a commercial VPN product built for general consumers, with China as the initial launch market. The system is designed from day one for restrictive-network resilience, strong privacy guarantees, and multi-platform reach (Android, iOS, Windows, macOS).

> **Status:** Planning / Architecture phase. No application code has been written yet. This repository currently contains foundational documentation only.

## Why OpenWorld VPN

- **Censorship-resilient by design** — WireGuard core with a pluggable obfuscation layer so connections are not trivially fingerprinted by deep packet inspection (DPI) on restrictive networks.
- **Privacy-first** — strict data-minimization / no-activity-logs policy (see [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md)).
- **Cross-platform native experience** — a single Flutter codebase powering Android, iOS, Windows, and macOS clients.
- **Independent, scalable backend** — the control plane (accounts, billing, server directory) is fully decoupled from the VPN data plane (WireGuard edge nodes), so each can scale and fail independently.

## Repository Structure

This repository is the **documentation and client umbrella repo**. Backend and VPN infrastructure live in separate private repositories (see [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md#repository--service-strategy)).

```
openvpn/
├── README.md                     # This file
├── PROJECT_BLUEPRINT.md          # Product vision, market, MVP scope, business model
├── SYSTEM_ARCHITECTURE.md        # Technical architecture, data flow, tech stack
├── DEVELOPMENT_ROADMAP.md        # Phased delivery plan (Phase 0 → GA)
├── DATABASE_DESIGN.md            # Data model for the backend control plane
├── SECURITY_GUIDELINES.md        # Security, privacy, and compliance standards
│
├── client/                       # (future) Flutter application source
│   ├── android/
│   ├── ios/
│   ├── windows/
│   ├── macos/
│   └── lib/
│       ├── core/                 # networking, VPN engine bindings, storage
│       ├── features/             # auth, subscription, connection, settings
│       └── shared/                # widgets, theming, utils
│
└── docs/                         # (future) ADRs, diagrams, API specs, runbooks
```

> Related repositories (private, separate from this one):
> - `openworld-backend-api` — REST/GraphQL control plane (auth, billing, server directory, device management)
> - `openworld-vpn-infra` — WireGuard node provisioning, orchestration, obfuscation gateways, IaC (Terraform/Ansible)

## Core Documentation

| Document | Purpose |
|---|---|
| [PROJECT_BLUEPRINT.md](PROJECT_BLUEPRINT.md) | Product vision, target market, MVP feature scope, subscription/business model |
| [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) | End-to-end architecture, technology choices, data flow, scaling strategy |
| [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) | Phased roadmap from MVP to GA and beyond |
| [DATABASE_DESIGN.md](DATABASE_DESIGN.md) | Data model, entity relationships, retention policy |
| [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md) | Security architecture, secure coding, compliance, incident response |

## Technology Snapshot

| Layer | Choice |
|---|---|
| Client | Flutter (Dart), platform channels for native WireGuard bindings |
| VPN protocol | WireGuard, with obfuscation transport (UDP camouflage) for restrictive networks |
| Backend API | REST API (Node.js/NestJS or Go — see blueprint), PostgreSQL, Redis |
| Infrastructure | Multi-region cloud + bare-metal mix, Terraform/Ansible, containerized services |
| Auth | Short-lived JWT access tokens + rotating refresh tokens, WireGuard key provisioning per device |
| Payments | Third-party PCI-compliant processors + regional payment methods |

## License & Confidentiality

This repository and its contents are **proprietary and confidential**. All rights reserved by OpenWorld VPN. Do not distribute outside the organization.
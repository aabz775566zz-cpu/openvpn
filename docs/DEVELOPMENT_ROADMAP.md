# Development Roadmap

This roadmap outlines the phased delivery plan for OpenWorld VPN. Each phase
builds on the previous one; scope may be adjusted as the project evolves.

## Phase 0 — Project Foundation (current phase)

- Establish repository structure (`apps/`, `backend/`, `infrastructure/`,
  `database/`, `docs/`, `tests/`, `.github/workflows/`).
- Define system architecture, database design, and security guidelines.
- No application code yet.

## Phase 1 — Backend Foundations

- Scaffold the TypeScript/Node.js REST API project in `backend/`.
- Implement core domain: user accounts, authentication, sessions.
- Establish database schema and migrations in `database/`.
- Set up CI pipeline (lint, build, test) in `.github/workflows/`.

## Phase 2 — VPN Infrastructure Foundations

- Scaffold WireGuard server provisioning in `infrastructure/vpn-server/`.
- Define server registration and health-check contract with the backend.
- Establish key management and configuration issuance flow.

## Phase 3 — Client Application (MVP)

- Scaffold the Flutter application in `apps/mobile/`.
- Implement authentication flows against the backend API.
- Implement English and Chinese localization.
- Implement VPN connect/disconnect using WireGuard configuration issued by
  the backend.

## Phase 4 — Admin Dashboard (MVP)

- Scaffold the admin dashboard application in `apps/admin/`.
- Implement user, subscription, and VPN server management views.
- Integrate with backend authentication for admin roles.

## Phase 5 — Subscriptions & Billing

- Integrate payment/subscription management into the backend.
- Reflect subscription state in the client application and admin dashboard.

## Phase 6 — China Market Launch Readiness

- Harden client connectivity against network interference.
- Finalize Chinese localization and in-market distribution requirements.
- Load-test VPN infrastructure and backend for expected launch traffic.

## Phase 7 — Scale & Expansion

- Expand server fleet across additional regions.
- Expand localization beyond English and Chinese as new markets are added.
- Continuous hardening based on production security and reliability
  learnings (see `SECURITY_GUIDELINES.md`).

## Ongoing Workstreams

- Security review and threat modeling at every phase.
- Automated testing (`tests/`) expanded alongside each new capability.
- Documentation (`docs/`) kept in sync with implementation decisions.

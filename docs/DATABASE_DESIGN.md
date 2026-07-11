# Database Design

> This document defines the intended data model and storage strategy for
> OpenWorld VPN. It will evolve as the backend is implemented; no schema is
> implemented yet — this is the design reference for Phase 1.

## 1. Storage Technology

- A relational database is expected for core transactional data (users,
  subscriptions, devices, server directory), given the need for strong
  consistency around billing and access control.
- Final technology selection (e.g., PostgreSQL) will be confirmed at the
  start of Phase 1 and recorded here.
- Schema migrations and seed data will live under `database/`.

## 2. Core Entities (conceptual)

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

## 3. Relationships (conceptual)

- A `User` has many `Device`s.
- A `User` has one active `Subscription` at a time (with historical
  records retained).
- A `Device` connects to a `VPN Server`, producing `Session` records.
- An `Admin User` is independent of `User` and has role-based access to
  manage the above entities via the Admin Dashboard.

## 4. Data Protection Principles

- No plaintext secrets, passwords, or private keys are ever persisted.
- Connection/session logs are minimized and retained only as long as
  operationally necessary.
- Personally identifiable information is limited to what is strictly
  required for account and billing functionality.

## 5. Next Steps (Phase 1)

- Select and confirm the database engine.
- Define concrete schema/migration files under `database/`.
- Define indexing and partitioning strategy for scale.

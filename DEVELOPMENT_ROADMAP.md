# Development Roadmap — OpenWorld VPN

This roadmap defines delivery phases by scope and dependency order rather than calendar dates. Each phase should be treated as a milestone gate — move to the next phase once exit criteria are met, not once a date passes.

## Phase 0 — Foundations (current phase)

**Goal:** Align on architecture and de-risk the hardest technical problems before writing product code.

- [x] Core documentation set (this document set).
- [ ] Finalize backend language/framework choice (Node.js/NestJS vs. Go).
- [ ] Finalize Flutter state management approach.
- [ ] Spike: WireGuard obfuscation transport prototype and DPI-resistance validation.
- [ ] Spike: native VPN integration proof-of-concept on Android (VpnService) and Windows.
- [ ] Stand up the three repositories (`openvpn`, `openworld-backend-api`, `openworld-vpn-infra`) with baseline CI.
- [ ] Legal/compliance kickoff for target market considerations (entity structure, hosting jurisdiction, app store policy review).

**Exit criteria:** Obfuscated WireGuard handshake proven end-to-end in a test environment; repo/CI skeletons exist; architecture decisions recorded as ADRs.

## Phase 1 — MVP (Android + Windows)

**Goal:** A user can install the app, create an account, subscribe, and reliably connect through an obfuscated WireGuard tunnel.

### Backend
- Auth Service: signup/login, JWT + refresh tokens, password hashing (Argon2id), basic rate limiting.
- Device Service: device registration, WireGuard keypair issuance/revocation, device list cap by plan.
- Billing Service: Google Play Billing integration, receipt validation, entitlement state, Redis entitlement cache.
- Server Directory Service: static/manually curated initial server list with health check endpoint.

### VPN Infrastructure
- WireGuard node image + baseline provisioning script (single cloud provider, 2–3 regions).
- First working version of the obfuscation gateway (from Phase 0 spike, hardened).
- Manual node rotation runbook (automation comes in Phase 2).

### Client (Flutter — Android, Windows)
- Signup/login screens, session persistence.
- Server list screen (auto-select + manual pick).
- Connect/disconnect with live status, obfuscated transport as default with plain WireGuard fallback toggle.
- Subscription/paywall screen wired to Play Billing (Windows uses web-based payment initially).
- Kill switch (Android + Windows).
- Basic settings: logout, device list, protocol mode.

**Exit criteria:** Internal dogfood build sustains stable connections from restrictive-network test vantage points; crash-free session rate above internal bar; store-review-ready builds for Android.

## Phase 2 — iOS + macOS Parity & Scale-Out

**Goal:** Full platform coverage and infrastructure that scales beyond a single provider/region set.

### Backend
- Apple StoreKit receipt validation added to Billing Service.
- Server Directory Service becomes dynamic (live load/latency scoring feeding client recommendations).
- Introduce message queue (Kafka/NATS) for billing + server health events.
- Split modular monolith into independently deployable services as load requires.

### VPN Infrastructure
- Node orchestrator automates provisioning/teardown and IP rotation across multiple providers.
- Multi-provider, multi-region PoP expansion.
- Automated blocklist-detection feedback loop (health checks flag degraded/blocked nodes for rotation).

### Client
- iOS Network Extension (Packet Tunnel Provider) implementation.
- macOS parity via shared Network Extension code path.
- Kill switch parity on iOS/macOS (within platform constraints).
- Shared connection-quality diagnostics screen across all 4 platforms.

**Exit criteria:** All four platforms in app stores (or documented alternate distribution channel), infra spans multiple providers/regions with automated rotation.

## Phase 3 — Growth Features & Hardening

**Goal:** Improve retention, differentiate the product, and harden security/privacy posture based on real-world usage data.

- Split tunneling (per-app or per-domain).
- Multi-hop connections (optional privacy feature).
- Referral / promo code system.
- In-app support (chat or ticketing integration).
- DNS-level ad/tracker blocking (opt-in).
- Independent third-party security audit of client + infrastructure.
- Formal no-logs policy audit/attestation.
- Expand payment methods for target market(s).

**Exit criteria:** Security audit completed with no unresolved criticals; measurable improvement in retention/conversion metrics from new features.

## Phase 4 — Platform & Market Expansion

**Goal:** Scale the business beyond the initial market and feature set.

- Additional target markets (region-specific PoP and payment method expansion).
- Team/family/enterprise plan tiers.
- Linux desktop client.
- Browser extension (proxy-only, lighter-weight product line) — evaluated as a separate product decision.
- Deeper analytics for infrastructure auto-scaling (predictive provisioning).

## Cross-Phase Workstreams (ongoing throughout all phases)

- **Security & Privacy:** threat modeling, dependency scanning, secure code review — continuous, not a phase-end activity (see [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md)).
- **Legal & Compliance:** revisit before each new market launch.
- **Reliability/On-call:** SRE practices introduced no later than Phase 1 production launch.
- **Documentation:** ADRs recorded for every significant architecture decision; this document set kept current as scope evolves.

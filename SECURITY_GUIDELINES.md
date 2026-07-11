# Security Guidelines — OpenWorld VPN

Security and privacy are core product features for OpenWorld VPN, not an afterthought. This document defines the baseline standards all code, infrastructure, and processes must meet. It should be read alongside [SYSTEM_ARCHITECTURE.md](SYSTEM_ARCHITECTURE.md) and [DATABASE_DESIGN.md](DATABASE_DESIGN.md).

## 1. Guiding Principles

1. **Data minimization** — never collect or store data we don't have a concrete, current need for.
2. **Least privilege** — every service, credential, and human access grant is scoped to the minimum required.
3. **Defense in depth** — no single control is trusted as the only line of defense.
4. **Assume breach** — design logging, segmentation, and rotation policies as if an attacker will eventually get partial access.
5. **Separation of control plane and data plane** — the backend never sees VPN traffic; VPN nodes never see billing/identity data beyond a scoped, short-lived authorization token.

## 2. No-Logs Policy

- No logging of destination IPs/domains, DNS queries, browsing content, or per-connection traffic content on VPN nodes.
- Only operational data required to run the service is retained (node health, aggregate/anonymized load metrics, short-lived session authorization tokens) — detailed in [DATABASE_DESIGN.md](DATABASE_DESIGN.md#4-what-we-deliberately-do-not-store).
- Any diagnostic logging on VPN nodes (e.g., for debugging an outage) must be time-boxed, scoped to the minimum necessary, and scrubbed of identifying details before persisting.
- The no-logs policy should be independently audited before general availability launch (see [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md), Phase 3) and the results published to build user trust.

## 3. Authentication & Account Security

- Passwords hashed with **Argon2id** (memory-hard, tuned parameters reviewed periodically as hardware improves). Never MD5/SHA1/plain SHA256 for password storage.
- Access tokens: short-lived JWTs (~15 minutes), signed with an asymmetric algorithm (e.g., RS256/EdDSA) so resource servers can verify without shared secrets.
- Refresh tokens: long-lived but rotating (single-use, replaced on each refresh) and bound to a specific device; only the hash is stored server-side.
- Full "log out of all devices" support by bulk-revoking auth sessions.
- Rate limiting and progressive backoff on login, signup, and password-reset endpoints to resist credential stuffing and brute force.
- Optional MFA (TOTP) planned as a post-MVP enhancement; architecture should not preclude adding it later.
- Device fingerprinting used only for fraud/trial-abuse detection, using non-reversible hashed identifiers — not for behavioral tracking.

## 4. Transport & Network Security

- All control-plane traffic over **TLS 1.3** only; TLS 1.0/1.1/1.2-only endpoints are not permitted.
- **Certificate pinning** in all official clients for control-plane API calls, with a safe, monitored rotation process for pinned certificates/keys to avoid bricking clients on cert renewal.
- VPN tunnel traffic uses **WireGuard** (ChaCha20-Poly1305, Curve25519, BLAKE2s) — no custom/home-grown cryptography.
- Obfuscation transport layer (for DPI resistance) wraps WireGuard traffic but must never weaken or replace WireGuard's own cryptographic guarantees — obfuscation is for traffic-shape camouflage, not a substitute for encryption.
- Private WireGuard keys are generated on-device and never transmitted; only public keys are sent to the backend for authorization (see [DATABASE_DESIGN.md](DATABASE_DESIGN.md#wireguard_keypair)).
- Internal service-to-service traffic (backend microservices, orchestrator-to-node) uses mutual TLS within a private network; no internal admin interface is exposed directly to the public internet.

## 5. Application (Client) Security

- VPN tunneling is implemented via native OS VPN APIs (Android `VpnService`, iOS/macOS `NetworkExtension`, Windows tunnel service) — Flutter/Dart layer only orchestrates UI and control-plane calls, never touches raw tunnel packets.
- Sensitive material (refresh tokens, WireGuard private keys) stored exclusively in OS-native secure storage (Android Keystore, iOS/macOS Keychain, Windows DPAPI) — never in `SharedPreferences`, plain files, or app logs.
- No sensitive data (tokens, keys, PII) written to application logs, crash reports, or analytics events.
- Kill switch: when enabled, all non-VPN traffic is blocked at the OS network layer if the tunnel drops unexpectedly, preventing IP/traffic leaks.
- DNS leak protection: all DNS resolution routed through the tunnel while connected.
- Dependency scanning (SCA) integrated into CI for both client and backend to catch known-vulnerable packages before release.
- Reproducible, signed release builds for every platform; release signing keys held in a secrets manager / HSM-backed process, not on individual developer machines.

## 6. Backend & Infrastructure Security

- Secrets (DB credentials, signing keys, processor API keys) live in a centralized secrets manager (cloud KMS/Vault) — never committed to source control or baked into container images.
- Principle of least privilege for IAM roles: backend services, the orchestrator, and CI pipelines each get narrowly scoped credentials.
- Network segmentation: control-plane databases are not reachable from the public internet or from the VPN data-plane network segment.
- Infrastructure changes (Terraform) go through code review and a plan/apply pipeline — no manual, untracked infrastructure changes in production.
- Regular automated dependency and container image scanning; base images kept patched on a defined cadence.
- Node provisioning images are built from a hardened, minimal base (unneeded services disabled, firewall default-deny with explicit allow rules).
- DDoS protection at the edge (both control-plane API and VPN gateway ingress) via provider-level mitigation and rate limiting.

## 7. Payment Security

- OpenWorld servers **never store or process raw payment card data**. All card handling is delegated to PCI-DSS-compliant processors and platform billing (Google Play Billing / Apple StoreKit); OpenWorld only stores processor-issued references/receipt IDs.
- Subscription receipts are validated server-side against the platform's official validation API (Play Developer API, App Store Server API) before entitlement is granted — client-reported purchase state is never trusted directly.
- Webhook endpoints from payment processors are authenticated (signature verification) and idempotent to prevent replay-based entitlement fraud.

## 8. Privacy & Compliance

- Only email/phone is collected as direct identifying information for the consumer account tier; no government ID, precise location, or browsing history is collected.
- Data subject rights (access, deletion/export where legally applicable, e.g., GDPR for EU users) supported by design — account deletion cascades to auth sessions and device keys, subject to the retention policy in [DATABASE_DESIGN.md](DATABASE_DESIGN.md#5-data-retention-policy-initial-draft--subject-to-legal-review).
- Privacy policy and terms of service must be reviewed by legal counsel per target market before launch, including specific review for markets with heightened regulatory sensitivity around VPN services.
- App store policy compliance (Apple/Google developer policies) reviewed before each release, particularly around VPN/proxy app category requirements.

## 9. Secure Development Lifecycle

- Threat modeling performed for each major new feature (especially anything touching auth, billing, or the connection-authorization flow), updated as an ongoing artifact rather than a one-time exercise.
- Mandatory code review for all changes, with security-sensitive areas (auth, crypto, payment, key handling) requiring review from the designated security lead.
- Static analysis (SAST) and dependency scanning (SCA) as required CI gates before merge.
- Secrets-scanning pre-commit/CI hook to prevent credential leaks into source control.
- Independent third-party penetration test and no-logs audit planned before general availability (Phase 3 of the roadmap).

## 10. Incident Response

- Defined on-call rotation and escalation path once Phase 1 reaches production traffic.
- Incident severity levels documented with target response expectations (no calendar SLAs published here; defined operationally by the on-call runbook).
- Post-incident reviews are blameless and produce action items tracked to completion.
- A responsible-disclosure / bug bounty channel should be established before general availability so external researchers have a safe reporting path.

## 11. Key & Credential Rotation

| Credential type | Rotation approach |
|---|---|
| Device WireGuard keypairs | User-initiated rotation supported; optional automatic rotation policy evaluated post-MVP |
| Backend signing keys (JWT) | Rotated on a defined schedule with overlapping validity window to avoid breaking in-flight tokens |
| TLS certificates (pinned) | Rotated with advance client-side pin update rollout to avoid breaking connectivity |
| Infrastructure/service credentials | Rotated via secrets manager on a defined schedule and immediately on suspected exposure |

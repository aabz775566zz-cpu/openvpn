# Project Blueprint — OpenWorld VPN

## 1. Vision

OpenWorld VPN gives general consumers a fast, reliable, and private way to access the open internet — even from networks that actively block or throttle VPN traffic. The product must feel as simple as "tap to connect" while running serious network engineering underneath.

**Primary launch market:** China (general consumer users).
**Secondary markets (post-MVP):** other regions with restrictive or unreliable internet access, followed by general global privacy-conscious consumers.

> **Compliance note:** Operating a VPN service targeted at users in heavily regulated markets carries real legal and regulatory exposure for the company, for app store distribution, and potentially for end users. Legal counsel with expertise in telecom/internet regulation in each target market must review go-to-market plans, app store listing strategy, and in-app messaging before launch. This document describes the technical/product plan only and is not legal advice.

## 2. Target Users

- General consumers (non-technical), primarily mobile-first.
- Needs: reliable access to blocked services, video/streaming performance, simple UX, trustworthy privacy story, affordable pricing, works even when the network is actively hostile to VPNs.
- Secondary persona: privacy-conscious users in open markets who want a fast, no-logs VPN with a clean app.

## 3. Product Principles

1. **It must connect.** Reliability against network interference is the #1 feature — everything else is secondary.
2. **Privacy is the product.** No browsing/activity logs, minimal account data, transparent data practices.
3. **One tap, no configuration.** Smart default server selection; advanced settings hidden behind an "Advanced" toggle.
4. **Native performance everywhere.** One Flutter codebase, but VPN data-plane work is done in native platform code (no VPN tunneling in Dart/UI thread).
5. **Decoupled control plane and data plane.** The backend (accounts/billing) never sees VPN traffic; VPN nodes never see billing/identity data beyond what's required to authorize a session.

## 4. Platforms

| Platform | Priority | Notes |
|---|---|---|
| Android | P0 (MVP) | `VpnService` API, widest reach in target market |
| Windows | P0 (MVP) | Desktop usage common for work-from-home / general use |
| iOS | P1 (fast-follow) | Network Extension (Packet Tunnel Provider), App Store review considerations |
| macOS | P1 (fast-follow) | Shares Network Extension code path with iOS where possible |

## 5. MVP Scope (Must-Have)

- Email/phone + password account creation and login.
- Device registration (list, name, revoke).
- One-tap connect/disconnect using WireGuard.
- Automatic "best server" selection + manual country/server list.
- Obfuscated transport mode (fallback when plain WireGuard is blocked).
- Subscription purchase via platform billing (Google Play Billing, Apple StoreKit) + one web-based payment option.
- Basic account management (plan status, renewal date, logout of all devices).
- Kill switch (block all traffic if VPN drops) — Android + Windows for MVP.
- Crash-free telemetry (aggregate, no per-user browsing data).

### Explicitly Out of Scope for MVP

- Split tunneling, multi-hop, dedicated IP, ad/tracker blocking, referral program, desktop Linux client, in-app support chat (use external support channel initially).

## 6. Subscription & Business Model

### Plan Types (initial)

| Plan | Billing cycle | Notes |
|---|---|---|
| Trial | 3–7 days, limited data or limited server list | Fraud controls required (device fingerprint + payment method binding) |
| Monthly | Recurring monthly | Standard entry plan |
| Annual | Recurring yearly | Primary discounted plan to drive retention |
| Multi-year | 2–3 year upfront | Optional, higher discount, cash-flow positive |

### Payment Approach

- **Mobile:** Google Play Billing / Apple In-App Purchase (required by store policy for digital subscriptions).
- **Web/Desktop:** Third-party PCI-compliant payment processor(s) supporting regional payment methods relevant to the target market (cards, wallets, etc.), selected after legal/compliance review.
- No raw card data ever touches OpenWorld servers (see [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md#payment-security)).
- Store-based receipts are validated server-side (Play Developer API / App Store Server API) before entitlement is granted.

### Entitlement Model

- A **Subscription** grants an **Entitlement** (e.g., `premium_access`) to an **Account**.
- Entitlement state is cached at the edge (short TTL) so VPN session authorization doesn't require a round trip to the primary database for every connect.
- Device count per account is limited by plan tier (e.g., 5 simultaneous devices).

## 7. High-Level Feature Roadmap (see [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) for phased detail)

- Phase 0: Architecture & foundations (this document set).
- Phase 1: MVP — Android + Windows, core connect flow, subscriptions.
- Phase 2: iOS + macOS parity, obfuscation hardening, multi-region scale-out.
- Phase 3: Growth features — split tunneling, referrals, in-app support, ad-block/DNS filtering.
- Phase 4: Platform expansion, enterprise/team plans, additional markets.

## 8. Success Metrics

- **Connection success rate** on restrictive networks (primary north-star metric).
- Time-to-first-successful-connection for a new install.
- 7-day / 30-day retention.
- Trial-to-paid conversion rate.
- Support ticket volume per 1,000 active users (proxy for reliability/UX issues).

## 9. Team & Ownership (initial structure)

| Area | Ownership |
|---|---|
| Client (Flutter) | Mobile/Desktop engineering |
| Backend API | Backend engineering |
| VPN Infrastructure | Network/Infra engineering (SRE) |
| Security & Compliance | Security lead (cross-cutting, reviews all areas) |
| Product/Design | Product owner |

## 10. Key Risks

| Risk | Mitigation |
|---|---|
| DPI blocking of VPN protocol | Pluggable obfuscation transport layer, rapid server rotation, protocol diversification |
| App store rejection/removal in restrictive markets | Maintain compliant primary distribution path + documented sideload/alternate distribution fallback plan |
| Legal exposure operating in a restrictive market | Ongoing legal counsel engagement; jurisdiction for company incorporation and data hosting chosen deliberately |
| Payment processor risk (chargebacks, regional restrictions) | Multiple processor relationships, fraud/velocity controls |
| Server/IP blocklisting | Rapid, automated IP rotation and provisioning pipeline (see architecture doc) |

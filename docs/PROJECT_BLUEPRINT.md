# OpenWorld VPN — Project Blueprint

## 1. Vision

OpenWorld VPN is a scalable, commercial-grade VPN product designed to provide
general users with fast, private, and reliable access to the open internet.
The first target market is China, where network restrictions and censorship
create strong demand for a dependable, easy-to-use VPN service.

## 2. Goals

- Deliver a polished, production-ready VPN client for the platforms users
  actually use every day: Android, iOS, Windows, and macOS.
- Provide a robust, secure, and horizontally scalable backend to manage
  users, subscriptions, devices, and VPN access.
- Operate a WireGuard-based VPN infrastructure that is fast, resilient to
  network interference, and decoupled from the business backend.
- Give the operations team full visibility and control through an admin
  dashboard.

## 3. Target Users

- General consumers seeking privacy, security, and unrestricted internet
  access.
- Primary market: China (with consideration for censorship-resistant
  connectivity and Chinese-language support).
- Secondary markets: English-speaking users globally.

## 4. High-Level Architecture

| Component               | Technology                     | Responsibility                                   |
|--------------------------|---------------------------------|---------------------------------------------------|
| Client Application       | Flutter (Dart)                  | Cross-platform app for Android/iOS/Windows/macOS  |
| Backend                  | TypeScript + Node.js (REST API) | Auth, users, subscriptions, device management     |
| VPN Infrastructure        | WireGuard                       | Encrypted tunnel, key management, traffic routing |
| Admin Dashboard           | Web application                 | Operations, monitoring, user & server management  |
| Database                 | TBD (see DATABASE_DESIGN.md)    | Persistent storage for backend & admin data       |

## 5. Repository Structure

```
/
├── apps/
│   ├── mobile/        # Flutter client application (Android, iOS, Windows, macOS)
│   └── admin/          # Admin dashboard web application
│
├── backend/            # TypeScript/Node.js REST API
│
├── infrastructure/
│   └── vpn-server/     # WireGuard-based VPN infrastructure (separate from backend)
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

## 6. Guiding Principles

- **Separation of concerns**: The VPN data plane (WireGuard infrastructure)
  is fully decoupled from the backend control plane. The backend never
  proxies user traffic; it only manages accounts and issues configuration.
- **Security first**: No secrets, credentials, or private keys are ever
  committed to the repository. See `SECURITY_GUIDELINES.md`.
- **Multi-language from day one**: The client ships with English and
  Chinese localization support baked into the architecture.
- **Scalability**: All components are designed to scale horizontally,
  anticipating growth from an initial launch market (China) to a global
  user base.

## 7. Related Documents

- `SYSTEM_ARCHITECTURE.md` — detailed technical architecture
- `DEVELOPMENT_ROADMAP.md` — phased delivery plan
- `DATABASE_DESIGN.md` — data model and storage strategy
- `SECURITY_GUIDELINES.md` — security and compliance guidelines

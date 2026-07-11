# Security Guidelines

These guidelines apply to all contributors and all components of OpenWorld
VPN (client, backend, VPN infrastructure, admin dashboard).

## 1. Secrets Management

- **Never** commit secrets, API keys, private keys, certificates, tokens,
  or credentials of any kind to the repository.
- All secrets must be provided via environment variables or a dedicated
  secrets manager at deploy time — never hard-coded.
- `.env` files containing real values must never be committed; only
  `.env.example` files with placeholder values are permitted.
- Rotate any credential immediately if it is ever suspected to have been
  exposed.

## 2. Authentication & Authorization

- All backend endpoints must enforce authentication and authorization
  appropriate to the resource being accessed.
- Admin Dashboard access must be restricted to authenticated administrators
  with role-based permissions; it must never share the same trust level as
  general user accounts.
- Passwords and credentials must be hashed using a strong, modern algorithm
  (e.g., bcrypt/argon2) — never stored or logged in plaintext.

## 3. Transport Security

- All client-backend and client-VPN communication must be encrypted in
  transit (HTTPS for REST APIs, WireGuard's built-in encryption for the
  VPN tunnel).
- Certificate/key validation must not be disabled or bypassed in any
  environment, including development.

## 4. VPN Infrastructure Security

- VPN infrastructure (WireGuard) must remain isolated from the backend's
  database and business logic — a compromised VPN node must not expose
  user account data.
- Server-side WireGuard private keys must be generated and stored securely
  on the node itself, never transmitted or logged in plaintext.
- Client device keys are treated as sensitive and are only exchanged over
  authenticated, encrypted channels.

## 5. Data Minimization & Privacy

- Do not log user browsing activity, traffic content, or destination
  metadata beyond what is strictly required for service operation and
  abuse prevention.
- Minimize retention of connection logs and personally identifiable
  information; define and document retention periods before launch.
- Be mindful of data protection expectations in the first target market
  (China) and any future markets, and adapt data handling policies as
  needed.

## 6. Secure Development Practices

- Dependencies must be kept up to date and monitored for known
  vulnerabilities.
- All code changes affecting authentication, authorization, cryptography,
  or the VPN data path require careful review before merging.
- Input validation is required on all backend API endpoints.
- No fake, mock, or placeholder VPN functionality may be shipped as if it
  were real security functionality.

## 7. Incident Response

- Any suspected security incident (leaked credential, vulnerability,
  unauthorized access) must be reported and addressed immediately,
  including credential rotation and, where applicable, user notification.

## 8. CI/CD Security

- Workflows in `.github/workflows/` must not print or persist secrets in
  logs.
- Access to deployment credentials in CI must be scoped to the minimum
  required permissions.

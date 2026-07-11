/**
 * Shared authentication types.
 *
 * These types define the provider abstraction and the JWT session
 * structure used across `auth.service.ts`, the providers, and the
 * middleware. Keeping them in one place avoids circular imports between
 * those modules.
 */

/** Identity providers supported by the authentication layer. */
export type AuthProviderName = 'google' | 'apple' | 'wechat';

/**
 * Normalized user profile returned by a provider after a successful
 * identity verification. Providers may expose additional raw fields, but
 * every provider must be able to produce at least this shape.
 */
export interface AuthUserProfile {
  /** Stable identifier for the user within the provider's system. */
  providerUserId: string;
  email: string | null;
  displayName: string | null;
}

/**
 * Common interface every identity provider must implement.
 *
 * `verifyIdentity` validates the credential presented by the client
 * (e.g. an OAuth/OIDC token) and returns an opaque, verified identifier
 * for the provider account. `getUserProfile` then resolves that
 * identifier to a normalized profile.
 *
 * In this phase, all providers return mocked responses — no real OAuth
 * flow or external API call is performed.
 */
export interface AuthProvider {
  readonly name: AuthProviderName;
  verifyIdentity(credential: string): Promise<string>;
  getUserProfile(providerUserId: string): Promise<AuthUserProfile>;
}

/** Request body accepted by `POST /api/v1/auth/login`. */
export interface LoginRequestBody {
  provider: AuthProviderName;
  /** Opaque credential to be verified by the selected provider. */
  credential: string;
}

/**
 * JWT session payload.
 *
 * `iat`/`exp` are standard JWT claims (issued-at / expiry, in seconds
 * since the epoch); they are populated automatically by `jsonwebtoken`
 * and surfaced here as `issuedAt`/`expiry`. `userId` is a custom claim
 * that plays the role of the standard `sub` (subject) claim, and
 * `provider` is a custom claim this codebase relies on.
 */
export interface SessionTokenPayload {
  /** The authenticated user's id (equivalent to the JWT `sub` claim). */
  userId: string;
  provider: AuthProviderName;
  /** Issued-at, seconds since epoch. */
  issuedAt: number;
  /** Expiry, seconds since epoch. */
  expiry: number;
}

/** Authenticated user info exposed on `req` after JWT validation. */
export interface AuthenticatedUser {
  userId: string;
  provider: AuthProviderName;
}

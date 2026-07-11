/**
 * Authentication service.
 *
 * Orchestrates the login flow (provider verification → user
 * resolution/creation → JWT issuance), JWT verification, and logout
 * (session revocation). This is the only module that should read/write
 * JWTs directly — controllers and middleware depend on this service
 * rather than `jsonwebtoken` directly.
 */
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { AppError } from '../utils/AppError';
import { AppleProvider } from './providers/apple.provider';
import { GoogleProvider } from './providers/google.provider';
import { WeChatProvider } from './providers/wechat.provider';
import {
  AuthProvider,
  AuthProviderName,
  AuthUserProfile,
  SessionTokenPayload,
} from './auth.types';

/** Registry of available identity providers, keyed by provider name. */
const providers: Record<AuthProviderName, AuthProvider> = {
  google: new GoogleProvider(),
  apple: new AppleProvider(),
  wechat: new WeChatProvider(),
};

/**
 * In-memory revocation store for logged-out tokens.
 *
 * This is a Phase 3 foundation only: it is process-local and not shared
 * across instances. A production deployment would back this with a
 * shared store (e.g. Redis) keyed by token id and TTL'd to the token's
 * expiry. Entries are pruned lazily on lookup/insert.
 */
const revokedTokens = new Map<string, number>();

function pruneExpiredRevocations(): void {
  const now = Math.floor(Date.now() / 1000);
  for (const [token, expiry] of revokedTokens) {
    if (expiry <= now) {
      revokedTokens.delete(token);
    }
  }
}

export interface LoginResult {
  token: string;
  profile: AuthUserProfile;
  payload: SessionTokenPayload;
}

export class AuthService {
  /** Resolves a provider implementation by name, or throws. */
  static getProvider(providerName: AuthProviderName): AuthProvider {
    const provider = providers[providerName];
    if (!provider) {
      throw new AppError(`Unsupported authentication provider: ${providerName}`, 400, 'UNSUPPORTED_PROVIDER');
    }
    return provider;
  }

  /**
   * Verifies a credential against the given provider and issues a JWT
   * session token for the resolved user profile.
   */
  static async login(providerName: AuthProviderName, credential: string): Promise<LoginResult> {
    const provider = AuthService.getProvider(providerName);

    const providerUserId = await provider.verifyIdentity(credential);
    const profile = await provider.getUserProfile(providerUserId);

    const issuedAt = Math.floor(Date.now() / 1000);
    const expiry = issuedAt + config.jwt.expiresInSeconds;

    const payload: SessionTokenPayload = {
      userId: profile.providerUserId,
      provider: provider.name,
      issuedAt,
      expiry,
    };

    const token = jwt.sign(
      { userId: payload.userId, provider: payload.provider },
      config.jwt.secret,
      { expiresIn: config.jwt.expiresInSeconds },
    );

    return { token, profile, payload };
  }

  /**
   * Verifies a JWT session token, returning its decoded payload.
   * Throws an `AppError` (401) if the token is missing, malformed,
   * expired, or has been revoked via `logout`.
   */
  static verifyToken(token: string): SessionTokenPayload {
    if (!token) {
      throw new AppError('Authentication token is required', 401, 'UNAUTHORIZED');
    }

    pruneExpiredRevocations();
    if (revokedTokens.has(token)) {
      throw new AppError('Authentication token has been revoked', 401, 'TOKEN_REVOKED');
    }

    try {
      const decoded = jwt.verify(token, config.jwt.secret) as jwt.JwtPayload;

      if (typeof decoded.userId !== 'string' || typeof decoded.provider !== 'string') {
        throw new AppError('Malformed authentication token', 401, 'INVALID_TOKEN');
      }

      return {
        userId: decoded.userId,
        provider: decoded.provider as AuthProviderName,
        issuedAt: decoded.iat ?? 0,
        expiry: decoded.exp ?? 0,
      };
    } catch (err) {
      if (err instanceof AppError) {
        throw err;
      }
      throw new AppError('Invalid or expired authentication token', 401, 'INVALID_TOKEN');
    }
  }

  /** Revokes a session token so it can no longer be used to authenticate. */
  static logout(token: string): void {
    if (!token) {
      return;
    }

    let expiry = Math.floor(Date.now() / 1000) + config.jwt.expiresInSeconds;
    try {
      const decoded = jwt.decode(token) as jwt.JwtPayload | null;
      if (decoded?.exp) {
        expiry = decoded.exp;
      }
    } catch {
      // Ignore decode failures; fall back to the default expiry above so
      // the (already-invalid) token is still recorded as revoked.
    }

    pruneExpiredRevocations();
    revokedTokens.set(token, expiry);
  }
}

export default AuthService;

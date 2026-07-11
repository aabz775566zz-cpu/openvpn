/**
 * Authentication middleware.
 *
 * Validates the Authorization request header (a bearer-scheme token
 * value) and attaches the decoded session (`req.auth`) for downstream
 * handlers. Use `requireAuth` to protect private routes.
 */
import { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/AppError';
import { AuthService } from '../auth.service';
import { AuthenticatedUser } from '../auth.types';

declare module 'express-serve-static-core' {
  interface Request {
    auth?: AuthenticatedUser;
  }
}

function extractBearerToken(req: Request): string | null {
  const header = req.headers.authorization;
  if (!header) {
    return null;
  }

  const parts = header.split(' ');
  if (parts.length !== 2) {
    return null;
  }

  const [scheme, token] = parts;
  if (scheme !== 'Bearer' || !token) {
    return null;
  }

  return token;
}

/**
 * Express middleware that requires a valid, non-revoked JWT session
 * token. Rejects the request with a 401 `AppError` if validation fails;
 * otherwise populates `req.auth` and calls `next()`.
 */
export function requireAuth(req: Request, _res: Response, next: NextFunction): void {
  try {
    const token = extractBearerToken(req);
    if (!token) {
      throw new AppError('Missing or malformed Authorization header', 401, 'UNAUTHORIZED');
    }

    const payload = AuthService.verifyToken(token);
    req.auth = { userId: payload.userId, provider: payload.provider };
    next();
  } catch (err) {
    next(err);
  }
}

export default requireAuth;

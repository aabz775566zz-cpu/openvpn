/**
 * Authentication controllers.
 *
 * Thin HTTP layer over `AuthService` — request/response shaping and
 * validation only; all authentication logic lives in the service.
 */
import { Request, Response } from 'express';
import { AppError } from '../utils/AppError';
import { AuthService } from './auth.service';
import { AuthProviderName, LoginRequestBody } from './auth.types';

const SUPPORTED_PROVIDERS: AuthProviderName[] = ['google', 'apple', 'wechat'];

function isSupportedProvider(value: unknown): value is AuthProviderName {
  return typeof value === 'string' && (SUPPORTED_PROVIDERS as string[]).includes(value);
}

/**
 * POST /api/v1/auth/login
 *
 * Body: `{ provider: 'google' | 'apple' | 'wechat', credential: string }`
 */
export async function login(req: Request, res: Response): Promise<void> {
  const body = req.body as Partial<LoginRequestBody>;

  if (!isSupportedProvider(body.provider)) {
    throw new AppError(
      `Invalid or missing provider. Supported providers: ${SUPPORTED_PROVIDERS.join(', ')}`,
      400,
      'INVALID_PROVIDER',
    );
  }

  if (!body.credential || typeof body.credential !== 'string') {
    throw new AppError('Missing or invalid credential', 400, 'INVALID_CREDENTIAL');
  }

  const { token, profile, payload } = await AuthService.login(body.provider, body.credential);

  res.status(200).json({
    status: 'ok',
    data: {
      token,
      user: {
        id: payload.userId,
        provider: payload.provider,
        email: profile.email,
        displayName: profile.displayName,
      },
    },
  });
}

/**
 * POST /api/v1/auth/logout
 *
 * Requires a valid session (see `requireAuth`). Revokes the presented
 * token so it can no longer be used to authenticate.
 */
export async function logout(req: Request, res: Response): Promise<void> {
  const header = req.headers.authorization ?? '';
  const [, token] = header.split(' ');

  AuthService.logout(token ?? '');

  res.status(200).json({
    status: 'ok',
    data: { message: 'Logged out successfully' },
  });
}

/**
 * GET /api/v1/auth/me
 *
 * Requires a valid session (see `requireAuth`). Returns the identity of
 * the currently authenticated user as encoded in their session token.
 */
export async function me(req: Request, res: Response): Promise<void> {
  if (!req.auth) {
    throw new AppError('Not authenticated', 401, 'UNAUTHORIZED');
  }

  res.status(200).json({
    status: 'ok',
    data: {
      userId: req.auth.userId,
      provider: req.auth.provider,
    },
  });
}

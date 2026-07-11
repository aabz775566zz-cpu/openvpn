/**
 * Authentication routes.
 *
 * Mounted at `${API_PREFIX}/auth` (see `../routes/v1/index.ts`).
 */
import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { login, logout, me } from './auth.controller';
import { requireAuth } from './middleware/auth.middleware';

const authRouter = Router();

// Authentication endpoints are common brute-force/credential-stuffing
// targets, so they are rate-limited per client IP in addition to
// requiring a valid session where applicable.
const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

authRouter.use(authRateLimiter);

authRouter.post('/login', login);
authRouter.post('/logout', requireAuth, logout);
authRouter.get('/me', requireAuth, me);

export default authRouter;

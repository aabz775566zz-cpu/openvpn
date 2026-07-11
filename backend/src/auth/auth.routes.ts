/**
 * Authentication routes.
 *
 * Mounted at `${API_PREFIX}/auth` (see `../routes/v1/index.ts`).
 */
import { Router } from 'express';
import { login, logout, me } from './auth.controller';
import { requireAuth } from './middleware/auth.middleware';

const authRouter = Router();

authRouter.post('/login', login);
authRouter.post('/logout', requireAuth, logout);
authRouter.get('/me', requireAuth, me);

export default authRouter;

import { Router } from 'express';
import authRouter from '../../auth/auth.routes';

/**
 * Root router for API version 1.
 *
 * Feature routers (auth, users, subscriptions, servers, etc.) are mounted
 * here as they are implemented.
 */
const v1Router = Router();

v1Router.use('/auth', authRouter);

export default v1Router;

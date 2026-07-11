import { Router } from 'express';

/**
 * Root router for API version 1.
 *
 * Feature routers (auth, users, subscriptions, servers, etc.) will be
 * mounted here in later development phases. Kept empty intentionally for
 * Phase 1 — no authentication, database, or VPN functionality yet.
 */
const v1Router = Router();

export default v1Router;

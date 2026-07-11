# api module

The API service exposes the HTTP endpoints consumed by the mobile app and admin
dashboard.

## Current status

Only a `GET /health` endpoint is implemented so far, returning a basic service
status payload. Real routes for authentication, subscriptions, and server
management will be added as those modules are implemented.

## Files

- `app.js` — builds and configures the Express application.
- `server.js` — entry point that starts the HTTP server (`npm start` from `backend/`).
- `__tests__/health.test.js` — test for the health-check endpoint.

## Running locally

```bash
cd backend
npm install
npm start
# in another terminal
curl http://localhost:3000/health
```

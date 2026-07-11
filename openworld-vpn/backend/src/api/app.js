// Express application for the OpenWorld VPN backend API service.
// This currently only exposes a health-check endpoint. Real API routes
// (auth, subscription, server-management) will be added in future steps.
const express = require('express');

function createApp() {
  const app = express();

  app.get('/health', (req, res) => {
    res.status(200).json({
      status: 'ok',
      service: 'openworld-vpn-backend',
      timestamp: new Date().toISOString(),
    });
  });

  return app;
}

module.exports = { createApp };

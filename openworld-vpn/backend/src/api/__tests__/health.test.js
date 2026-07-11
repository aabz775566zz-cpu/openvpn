const request = require('supertest');
const { createApp } = require('../app');

describe('GET /health', () => {
  it('returns a 200 status with service health information', async () => {
    const app = createApp();

    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ok',
      service: 'openworld-vpn-backend',
    });
    expect(typeof response.body.timestamp).toBe('string');
  });
});

import request from 'supertest';
import { createApp } from '../src/app';

const app = createApp();

describe('Unmatched routes and error handling', () => {
  it('returns a 404 JSON error for unknown routes', async () => {
    const response = await request(app).get('/does-not-exist');

    expect(response.status).toBe(404);
    expect(response.body.status).toBe('error');
    expect(response.body.error.code).toBe('NOT_FOUND');
  });

  it('returns a 404 JSON error for unknown versioned API routes', async () => {
    const response = await request(app).get('/api/v1/does-not-exist');

    expect(response.status).toBe(404);
    expect(response.body.status).toBe('error');
  });
});

import jwt from 'jsonwebtoken';
import request from 'supertest';
import { createApp } from '../src/app';
import { config } from '../src/config';

const app = createApp();

/** Builds an Authorization header value for the given raw token. */
function authHeader(token: string): string {
  return ['Bearer', token].join(' ');
}

describe('POST /api/v1/auth/login', () => {
  it('logs in successfully with a valid mock Google credential', async () => {
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'google', credential: 'mock-google-token-user-1' });

    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
    expect(typeof response.body.data.token).toBe('string');
    expect(response.body.data.user).toEqual({
      id: 'user-1',
      provider: 'google',
      email: 'user-1@gmail.example.com',
      displayName: 'Google User user-1',
    });
  });

  it('logs in successfully with a valid mock Apple credential', async () => {
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'apple', credential: 'mock-apple-token-user-2' });

    expect(response.status).toBe(200);
    expect(response.body.data.user.provider).toBe('apple');
  });

  it('logs in successfully with a valid mock WeChat credential', async () => {
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'wechat', credential: 'mock-wechat-token-user-3' });

    expect(response.status).toBe(200);
    expect(response.body.data.user.provider).toBe('wechat');
    expect(response.body.data.user.email).toBeNull();
  });

  it('rejects an unsupported provider', async () => {
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'facebook', credential: 'anything' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('INVALID_PROVIDER');
  });

  it('rejects a missing credential', async () => {
    const response = await request(app).post('/api/v1/auth/login').send({ provider: 'google' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('INVALID_CREDENTIAL');
  });

  it('rejects a malformed provider credential', async () => {
    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'google', credential: 'not-a-real-token' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_CREDENTIAL');
  });
});

describe('GET /api/v1/auth/me', () => {
  it('returns the authenticated user for a valid token', async () => {
    const loginResponse = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'google', credential: 'mock-google-token-user-4' });

    const { token } = loginResponse.body.data;

    const meResponse = await request(app).get('/api/v1/auth/me').set('Authorization', authHeader(token));

    expect(meResponse.status).toBe(200);
    expect(meResponse.body.data).toEqual({ userId: 'user-4', provider: 'google' });
  });

  it('rejects a request with no Authorization header', async () => {
    const response = await request(app).get('/api/v1/auth/me');

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects a request with a malformed Authorization header', async () => {
    const response = await request(app).get('/api/v1/auth/me').set('Authorization', 'Token abc123');

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects a request with an invalid/garbage token', async () => {
    const response = await request(app).get('/api/v1/auth/me').set('Authorization', authHeader('garbage-not-a-jwt'));

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_TOKEN');
  });

  it('rejects a request with a token signed by a different secret', async () => {
    const forgedToken = jwt.sign({ userId: 'attacker', provider: 'google' }, 'wrong-secret', {
      expiresIn: 3600,
    });

    const response = await request(app).get('/api/v1/auth/me').set('Authorization', authHeader(forgedToken));

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_TOKEN');
  });

  it('rejects a request with an expired token', async () => {
    const expiredToken = jwt.sign({ userId: 'user-5', provider: 'google' }, config.jwt.secret, {
      expiresIn: -10,
    });

    const response = await request(app).get('/api/v1/auth/me').set('Authorization', authHeader(expiredToken));

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_TOKEN');
  });
});

describe('POST /api/v1/auth/logout', () => {
  it('revokes the session token so it can no longer be used', async () => {
    const loginResponse = await request(app)
      .post('/api/v1/auth/login')
      .send({ provider: 'apple', credential: 'mock-apple-token-user-6' });

    const { token } = loginResponse.body.data;

    const logoutResponse = await request(app)
      .post('/api/v1/auth/logout')
      .set('Authorization', authHeader(token));

    expect(logoutResponse.status).toBe(200);
    expect(logoutResponse.body.data.message).toBe('Logged out successfully');

    const meResponse = await request(app).get('/api/v1/auth/me').set('Authorization', authHeader(token));

    expect(meResponse.status).toBe(401);
    expect(meResponse.body.error.code).toBe('TOKEN_REVOKED');
  });

  it('rejects logout when not authenticated', async () => {
    const response = await request(app).post('/api/v1/auth/logout');

    expect(response.status).toBe(401);
  });
});

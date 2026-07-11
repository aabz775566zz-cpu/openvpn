/**
 * Apple identity provider (mock).
 *
 * Phase 3 scope: no real "Sign in with Apple" integration exists yet.
 * This provider validates a mock credential format and returns a
 * deterministic mocked profile — no external API is called.
 */
import { AppError } from '../../utils/AppError';
import { AuthProvider, AuthUserProfile } from '../auth.types';

const MOCK_CREDENTIAL_PREFIX = 'mock-apple-token-';

export class AppleProvider implements AuthProvider {
  readonly name = 'apple' as const;

  async verifyIdentity(credential: string): Promise<string> {
    if (!credential || !credential.startsWith(MOCK_CREDENTIAL_PREFIX)) {
      throw new AppError('Invalid Apple credential', 401, 'INVALID_CREDENTIAL');
    }

    return credential.slice(MOCK_CREDENTIAL_PREFIX.length);
  }

  async getUserProfile(providerUserId: string): Promise<AuthUserProfile> {
    return {
      providerUserId,
      // Apple's real flow may withhold email on subsequent logins; mocked
      // here as present for simplicity.
      email: `${providerUserId}@privaterelay.example.com`,
      displayName: `Apple User ${providerUserId}`,
    };
  }
}

export default AppleProvider;

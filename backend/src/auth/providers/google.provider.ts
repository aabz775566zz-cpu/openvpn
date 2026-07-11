/**
 * Google identity provider (mock).
 *
 * Phase 3 scope: no real Google OAuth/OIDC integration exists yet. This
 * provider validates a mock credential format and returns a deterministic
 * mocked profile so the authentication flow can be exercised end-to-end
 * without calling any external API or requiring real OAuth keys.
 */
import { AppError } from '../../utils/AppError';
import { AuthProvider, AuthUserProfile } from '../auth.types';

const MOCK_CREDENTIAL_PREFIX = 'mock-google-token-';

export class GoogleProvider implements AuthProvider {
  readonly name = 'google' as const;

  async verifyIdentity(credential: string): Promise<string> {
    if (!credential || !credential.startsWith(MOCK_CREDENTIAL_PREFIX)) {
      throw new AppError('Invalid Google credential', 401, 'INVALID_CREDENTIAL');
    }

    return credential.slice(MOCK_CREDENTIAL_PREFIX.length);
  }

  async getUserProfile(providerUserId: string): Promise<AuthUserProfile> {
    return {
      providerUserId,
      email: `${providerUserId}@gmail.example.com`,
      displayName: `Google User ${providerUserId}`,
    };
  }
}

export default GoogleProvider;

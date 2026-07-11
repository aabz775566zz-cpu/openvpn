/**
 * WeChat identity provider (mock).
 *
 * Phase 3 scope: no real WeChat OAuth integration exists yet. This
 * provider validates a mock credential format and returns a deterministic
 * mocked profile — no external API is called. WeChat is a primary
 * provider for the initial target market (China) per
 * `../../../docs/PROJECT_BLUEPRINT.md`.
 */
import { AppError } from '../../utils/AppError';
import { AuthProvider, AuthUserProfile } from '../auth.types';

const MOCK_CREDENTIAL_PREFIX = 'mock-wechat-token-';

export class WeChatProvider implements AuthProvider {
  readonly name = 'wechat' as const;

  async verifyIdentity(credential: string): Promise<string> {
    if (!credential || !credential.startsWith(MOCK_CREDENTIAL_PREFIX)) {
      throw new AppError('Invalid WeChat credential', 401, 'INVALID_CREDENTIAL');
    }

    return credential.slice(MOCK_CREDENTIAL_PREFIX.length);
  }

  async getUserProfile(providerUserId: string): Promise<AuthUserProfile> {
    return {
      providerUserId,
      // WeChat accounts are not guaranteed to expose an email address.
      email: null,
      displayName: `WeChat User ${providerUserId}`,
    };
  }
}

export default WeChatProvider;

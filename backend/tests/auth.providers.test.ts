import { AppleProvider } from '../src/auth/providers/apple.provider';
import { GoogleProvider } from '../src/auth/providers/google.provider';
import { WeChatProvider } from '../src/auth/providers/wechat.provider';
import { AuthProvider } from '../src/auth/auth.types';

/**
 * Verifies that every provider implements the common `AuthProvider`
 * abstraction (`verifyIdentity` + `getUserProfile`) consistently, using
 * only mocked credentials/responses — no external API calls are made.
 */
describe('Provider abstraction', () => {
  const providers: Array<{ provider: AuthProvider; credentialPrefix: string }> = [
    { provider: new GoogleProvider(), credentialPrefix: 'mock-google-token-' },
    { provider: new AppleProvider(), credentialPrefix: 'mock-apple-token-' },
    { provider: new WeChatProvider(), credentialPrefix: 'mock-wechat-token-' },
  ];

  it.each(providers)(
    '$provider.name provider verifies a valid credential and resolves a profile',
    async ({ provider, credentialPrefix }) => {
      const providerUserId = await provider.verifyIdentity(`${credentialPrefix}abc123`);
      expect(providerUserId).toBe('abc123');

      const profile = await provider.getUserProfile(providerUserId);
      expect(profile.providerUserId).toBe('abc123');
      expect(typeof profile.displayName).toBe('string');
    },
  );

  it.each(providers)('$provider.name provider rejects an empty credential', async ({ provider }) => {
    await expect(provider.verifyIdentity('')).rejects.toThrow();
  });

  it.each(providers)(
    '$provider.name provider rejects a credential from a different provider',
    async ({ provider }) => {
      await expect(provider.verifyIdentity('mock-unknown-token-abc123')).rejects.toThrow();
    },
  );

  it('exposes a distinct, stable name for each provider', () => {
    const names = providers.map(({ provider }) => provider.name);
    expect(new Set(names).size).toBe(names.length);
    expect(names.sort()).toEqual(['apple', 'google', 'wechat']);
  });
});

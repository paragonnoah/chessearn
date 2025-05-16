import { setNavigate } from './index';

export const CSRF_TOKENS = {
  access: 'csrf_access_token',
  refresh: 'csrf_refresh_token',
};

function getCookie(name) {
  const match = document.cookie.match(new RegExp(`(^| )${name}=([^;]+)`));
  return match ? match[2] : null;
}

/**
 * Returns CSRF headers for the request, if needed.
 */
export function getCsrfHeader(config) {
  const url = config.url || '';
  const method = (config.method || '').toLowerCase();

  // Only apply CSRF for mutating methods
  if (!['post', 'put', 'delete'].includes(method)) {
    return {};
  }

  const tokenName = url.includes('/auth/refresh') ? CSRF_TOKENS.refresh : CSRF_TOKENS.access;
  const token = getCookie(tokenName);

  if (!token) {
    console.warn(`Missing CSRF token: ${tokenName}`);
    return {}; // Rely on api/index.js interceptor for redirect
  }

  return { 'X-CSRF-TOKEN': token };
}
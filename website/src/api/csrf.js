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
 * Returns an object of any CSRF headers needed by this request.
 */
export function getCsrfHeader(config) {
  const url = config.url || '';
  const method = (config.method || '').toLowerCase();

  let tokenName = null;
  if (url.includes('/auth/refresh')) {
    tokenName = CSRF_TOKENS.refresh;
  } else if (['post', 'put', 'delete', 'get'].includes(method)) {
    tokenName = CSRF_TOKENS.access;
  }

  if (tokenName) {
    const token = getCookie(tokenName);
    if (!token) {
      console.warn(`Missing CSRF token: ${tokenName}`);
      // Trigger redirect to login if no token
      if (setNavigate && typeof setNavigate === 'function') {
        setNavigate(`/login?redirect=${encodeURIComponent(window.location.pathname)}`);
      } else {
        window.location.href = `/login?redirect=${encodeURIComponent(window.location.pathname)}`;
      }
      return {};
    }
    return { 'X-CSRF-Token': token };
  }
  return {};
}
import axios from 'axios';
import { getCsrfHeader } from './csrf';

// Base URL from environment
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'https://v2.chessearn.com',
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Attach CSRF headers for mutating requests
apiClient.interceptors.request.use((config) => {
  if (['POST', 'PUT', 'DELETE'].includes(config.method.toUpperCase())) {
    config.headers = { ...config.headers, ...getCsrfHeader(config) };
  }
  return config;
});

// Refresh token management
let isRefreshing = false;
let pendingRequests = [];
let refreshFailed = false;
let lastRefresh = 0;
const REFRESH_COOLDOWN = 1000; // 1s

// Handlers
let navigateFn = null;
let onError = null;

export const setNavigate = (fn) => {
  navigateFn = fn;
};

export const setErrorHandler = (fn) => {
  onError = fn;
};

export const resetRefreshFailed = () => {
  refreshFailed = false;
};

export const clearPendingRequests = () => {
  pendingRequests = [];
};

// Cleanup on unload
window.addEventListener('beforeunload', clearPendingRequests);

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const origReq = error.config;
    const status = error.response?.status;

    if (refreshFailed) {
      return Promise.reject(error);
    }

    if (
      status === 401 &&
      !origReq._retry &&
      !origReq.url.includes('/auth/') // Exclude all /auth endpoints
    ) {
      origReq._retry = true;

      if (!isRefreshing && Date.now() - lastRefresh > REFRESH_COOLDOWN) {
        isRefreshing = true;
        lastRefresh = Date.now();

        try {
          await apiClient.post('/auth/refresh');
          isRefreshing = false;
          pendingRequests.forEach((cb) => cb());
          pendingRequests = [];
          return apiClient(origReq);
        } catch (refreshErr) {
          isRefreshing = false;
          refreshFailed = true;

          onError?.('Session expired. Please log in again.');

          pendingRequests.forEach((cb) => cb(Promise.reject(refreshErr)));
          pendingRequests = [];

          const redirectPath = `/login?redirect=${encodeURIComponent(
            window.location.pathname
          )}`;
          navigateFn ? navigateFn(redirectPath) : (window.location.href = redirectPath);
          return Promise.reject(refreshErr);
        }
      }

      // Queue request
      return new Promise((resolve, reject) => {
        pendingRequests.push((retry) => {
          if (retry instanceof Promise) {
            retry.then(resolve).catch(reject);
          } else {
            resolve(apiClient(origReq));
          }
        });
      });
    }

    return Promise.reject(error);
  }
);

export default apiClient;
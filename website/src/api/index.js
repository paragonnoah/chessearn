import axios from 'axios';
import { getCsrfHeader } from './csrf';

// Base URL from environment (Vite, CRA, etc.)
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || 'https://v2.chessearn.com',
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Attach CSRF headers to mutating requests / refresh
apiClient.interceptors.request.use(config => {
  config.headers = {
    ...config.headers,
    ...getCsrfHeader(config),
  };
  return config;
});

// Queue up concurrent 401s so we only call /auth/refresh once
let isRefreshing = false;
let pendingRequests = [];

apiClient.interceptors.response.use(
  response => response,
  async error => {
    const origReq = error.config;
    const status  = error.response?.status;

    // Only attempt refresh on access‑token 401, skip if already retrying auth routes
    if (status === 401 &&
        !origReq._retry &&
        !origReq.url.includes('/auth/login') &&
        !origReq.url.includes('/auth/refresh')) {

      origReq._retry = true;

      if (!isRefreshing) {
        isRefreshing = true;
        try {
          await apiClient.post('/auth/refresh');
          isRefreshing = false;
          pendingRequests.forEach(cb => cb());
          pendingRequests = [];
        } catch (refreshErr) {
          isRefreshing = false;
          // redirect to login, preserving current path
          window.location.href = `/login?redirect=${encodeURIComponent(window.location.pathname)}`;
          return Promise.reject(refreshErr);
        }
      }

      return new Promise(resolve => {
        pendingRequests.push(() => resolve(apiClient(origReq)));
      });
    }

    return Promise.reject(error);
  }
);

export default apiClient;

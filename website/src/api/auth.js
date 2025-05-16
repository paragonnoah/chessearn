import apiClient, { resetRefreshFailed } from './index';

/**
 * Wraps a POST call in try/catch to normalize errors.
 * Returns { success, data } or throws { success, error, status }.
 */
async function safePost(url, payload) {
  try {
    const res = await apiClient.post(url, payload);
    return { success: true, data: res.data };
  } catch (err) {
    throw {
      success: false,
      error: err.response?.data?.message || err.message,
      status: err.response?.status,
    };
  }
}

export const register = async (userData) => {
  return await safePost('/auth/register', userData);
};

export const login = async (credentials) => {
  const result = await safePost('/auth/login', credentials);
  if (result.success) {
    resetRefreshFailed();
  }
  return result;
};

export const refreshToken = async () => {
  return await safePost('/auth/refresh', {});
};

export const logout = async () => {
  return await safePost('/auth/logout', {});
};
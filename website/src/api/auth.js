import apiClient from './index';

/**
 * Wraps a call in try/catch to normalize errors.
 * Throws either response.data or the raw error.
 */
async function safePost(url, payload) {
  try {
    const res = await apiClient.post(url, payload);
    return res.data;
  } catch (err) {
    // if server sent JSON error body, propagate that
    throw err.response?.data || err;
  }
}

export const register = async userData => {
  return await safePost('/auth/register', userData);
};

export const login = async credentials => {
  return await safePost('/auth/login', credentials);
};

export const refreshToken = async () => {
  return await safePost('/auth/refresh', {});
};

export const logout = async () => {
  return await safePost('/auth/logout', {});
};

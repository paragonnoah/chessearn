import apiClient from './index';

/**
 * Wraps a GET call, returns data or throws error.
 */
async function safeGet(url) {
  try {
    const res = await apiClient.get(url);
    return res.data;
  } catch (err) {
    throw {
      error: err.response?.data?.message || err.message,
      status: err.response?.status,
    };
  }
}

/**
 * Wraps a POST call, returns data or throws error.
 */
async function safePost(url, payload, config = {}) {
  try {
    const res = await apiClient.post(url, payload, config);
    return res.data;
  } catch (err) {
    throw {
      error: err.response?.data?.message || err.message,
      status: err.response?.status,
    };
  }
}

/**
 * Fetches the current user's profile.
 */
export const getProfile = async () => {
  return await safeGet('/profile');
};

/**
 * Uploads a profile photo. Expects a File object.
 */
export const uploadPhoto = async (file) => {
  const formData = new FormData();
  formData.append('photo', file);
  return await safePost('/profile/photo', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
};
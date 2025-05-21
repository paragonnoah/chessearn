// src/api/profile.js
import apiClient from './index';

async function safeGet(url) {
  try {
    const res = await apiClient.get(url);
    return res.data;
  } catch (err) {
    throw err.response?.data || err;
  }
}

async function safePost(url, payload, config) {
  try {
    const res = await apiClient.post(url, payload, config);
    return res.data;
  } catch (err) {
    throw err.response?.data || err;
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
  return await safePost(
    '/profile/photo',
    formData,
    { headers: { 'Content-Type': 'multipart/form-data' } }
  );
};

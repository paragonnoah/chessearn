import { apiRequest } from "../utils/api";

/**
 * Fetch the current user's profile.
 * @returns {Promise<Object>} Profile data
 */
export function getProfile() {
  return apiRequest("/profile", { method: "GET" });
}

/**
 * Upload a new profile photo.
 * @param {File} file - The file to upload.
 * @returns {Promise<Object>} Upload result
 */
export function uploadProfilePhoto(file) {
  const formData = new FormData();
  formData.append("photo", file);

  // apiRequest will handle CSRF and credentials
  return apiRequest("/profile/photo", {
    method: "POST",
    formData,
  });
}

/**
 * Get a user's profile photo as a Blob.
 * @param {string} userId - The user's UUID.
 * @returns {Promise<Blob>} The photo blob.
 */
export function getProfilePhoto(userId) {
  return apiRequest(`/profile/photo/${userId}`, {
    method: "GET",
    withCredentials: false, // since it's public
  });
}
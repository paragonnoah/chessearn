import { getProfile, uploadPhoto } from '../api/profile';

export const profileService = {
  /**
   * Fetches the current user's profile.
   */
  getProfile: () => getProfile(),

  /**
   * Uploads a profile photo. Expects a File object.
   */
  uploadPhoto: (file) => uploadPhoto(file),
};
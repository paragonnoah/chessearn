// src/services/profileService.js
import * as profileApi from '../api/profile';

export const profileService = {
  getProfile: profileApi.getProfile,
  uploadPhoto: profileApi.uploadPhoto,
};


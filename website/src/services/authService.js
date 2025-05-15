import * as authApi from '../api/auth';
import apiClient from '../api/index';

export const authService = {
  register: userData    => authApi.register(userData),
  login:    credentials => authApi.login(credentials),
  logout:   ()          => authApi.logout(),
  refresh:  ()          => authApi.refreshToken(),

  // example: fetch the current user’s profile
  getProfile: ()        => apiClient.get('/profile').then(res => res.data),
};

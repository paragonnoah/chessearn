import * as authApi from '../api/auth';
import { getProfile } from '../api/profile';

export const authService = {
  register: (userData) => authApi.register(userData),
  login: (credentials) => authApi.login(credentials),
  logout: () => authApi.logout(),
  refresh: () => authApi.refreshToken(),
  getProfile: () => getProfile(),
};
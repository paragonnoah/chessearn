import * as authApi from '../api/auth';
import apiClient from '../api/index';

export const authService = {
  register: userData => authApi.register(userData),
  login: credentials => authApi.login(credentials),
  logout: () => authApi.logout(),
  refresh: () => authApi.refreshToken(),

  getProfile: async () => {
    try {
      const res = await apiClient.get('/profile');
      return { success: true, data: res.data };
    } catch (err) {
      throw { success: false, error: err.response?.data || err.message };
    }
  },
};
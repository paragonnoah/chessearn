import React, { createContext, useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { setNavigate, setErrorHandler } from '../api/index';
import { toast } from 'react-toastify';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  // Set navigation and error handling
  useEffect(() => {
    setNavigate(navigate);
    setErrorHandler((message) => toast.error(message));
  }, [navigate]);

  // Load user profile
  const loadUser = async () => {
    try {
      const profile = await authService.getProfile();
      setUser(profile);
    } catch (err) {
      setUser(null);
      // Redirect handled by api/index.js 401 interceptor
    } finally {
      setLoading(false);
    }
  };

  // Initial load
  useEffect(() => {
    loadUser();
  }, []);

  // Login
  const login = async (credentials) => {
    setLoading(true);
    try {
      await authService.login(credentials);
      await loadUser();
    } catch (err) {
      setUser(null);
      throw { message: err.error || 'Login failed' };
    } finally {
      setLoading(false);
    }
  };

  // Logout
  const logout = async () => {
    try {
      await authService.logout();
    } catch (err) {
      // Log error but proceed with logout
      console.warn('Logout error:', err);
    } finally {
      setUser(null);
      setLoading(false);
      navigate('/login');
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
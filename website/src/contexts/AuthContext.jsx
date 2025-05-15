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

  // Set up navigation and error handling
  useEffect(() => {
    setNavigate(navigate);
    setErrorHandler(message => toast.error(message));
  }, [navigate]);

  const loadUser = async (retries = 3, delay = 1000) => {
    setLoading(true);
    for (let i = 0; i < retries; i++) {
      try {
        const profile = await authService.getProfile();
        setUser(profile.data);
        setLoading(false);
        return;
      } catch (err) {
        if (i === retries - 1) {
          setUser(null);
          setLoading(false);
          navigate(`/login?redirect=${encodeURIComponent(window.location.pathname)}`);
          return;
        }
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  };

  useEffect(() => {
    loadUser();
  }, []);

  const login = async (credentials) => {
    setLoading(true);
    try {
      await authService.login(credentials);
      await loadUser();
    } catch (err) {
      setUser(null);
      setLoading(false);
      throw { message: err.error || 'Login failed' };
    }
  };

  const logout = async () => {
    try {
      await authService.logout();
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
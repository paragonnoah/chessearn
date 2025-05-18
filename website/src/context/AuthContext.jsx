import React, { createContext, useContext, useEffect, useState, useCallback } from "react";
import { apiRequest } from "../utils/api";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Try to refresh user session on mount
  useEffect(() => {
    refresh().finally(() => setLoading(false));
    // eslint-disable-next-line
  }, []);

  // Register
  const register = async (form) => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiRequest("/auth/register", { method: "POST", data: form });
      // Optionally log the user in after register, or ask them to log in
      return res;
    } catch (err) {
      setError(err?.message || "Registration failed");
      throw err;
    } finally {
      setLoading(false);
    }
  };

  // Login
  const login = async (form) => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiRequest("/auth/login", { method: "POST", data: form });
      setUser(res.user);
      return res.user;
    } catch (err) {
      setError(err?.message || "Login failed");
      throw err;
    } finally {
      setLoading(false);
    }
  };

  // Refresh
  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await apiRequest("/auth/refresh", { method: "POST" });
      setUser(res.user);
      return res.user;
    } catch (err) {
      setUser(null);
      setError("Session expired. Please log in.");
    } finally {
      setLoading(false);
    }
  }, []);

  // Logout
  const logout = async () => {
    setLoading(true);
    setError(null);
    try {
      await apiRequest("/auth/logout", { method: "POST" });
      setUser(null);
    } catch (err) {
      setError("Logout failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, error, register, login, refresh, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
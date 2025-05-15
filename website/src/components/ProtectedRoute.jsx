
/*
  File: src/components/ProtectedRoute.jsx
  Guards routes based on authentication and optional role.
*/
import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

/**
 * @param {string[]} [roles]  List of roles allowed (e.g. ['admin']).
 */
const ProtectedRoute = ({ roles }) => {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!user) {
    return <Navigate to={`/login?redirect=${encodeURIComponent(location.pathname)}`} replace />;
  }

  if (roles && !roles.includes(user.role)) {
    // Optionally redirect or show "Not authorized"
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;

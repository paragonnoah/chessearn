import React, { useEffect, useState } from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const ProtectedRoute = ({ roles }) => {
  const { user, loading } = useAuth();
  const location = useLocation();
  const [debouncedRedirect, setDebouncedRedirect] = useState(null);

  useEffect(() => {
    if (!loading && !user) {
      const timer = setTimeout(() => {
        setDebouncedRedirect(`/login?redirect=${encodeURIComponent(location.pathname)}`);
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [loading, user, location.pathname]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (debouncedRedirect) {
    return <Navigate to={debouncedRedirect} replace />;
  }

  if (roles && user && !roles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
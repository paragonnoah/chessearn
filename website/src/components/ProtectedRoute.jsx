import React from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

/**
 * Wrap your protected routes in this component.
 * If not authenticated, user will be redirected to /login.
 * Usage: <ProtectedRoute><Profile /></ProtectedRoute>
 */
export default function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();

  // Optionally, show a loading spinner while auth is being determined
  if (loading) {
    return (
      <div className="flex justify-center items-center h-64 text-lg">
        Loading...
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return children;
}
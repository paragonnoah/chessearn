import React from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Navbar() {
  const { user, logout, loading } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate("/login");
  };

  return (
    <nav className="bg-gray-900 text-white px-6 py-4 flex items-center justify-between shadow">
      <Link to="/" className="text-2xl font-bold tracking-tight flex items-center gap-2">
        <span role="img" aria-label="Chess">♟️</span>
        <span>ChessEarn</span>
      </Link>
      <div className="flex items-center gap-4">
        {user ? (
          <>
            <Link
              to="/profile"
              className="hidden sm:inline text-yellow-400 font-semibold hover:underline hover:text-yellow-300 transition"
              title="Go to profile"
            >
              {user.username}
            </Link>
            <button
              onClick={handleLogout}
              className="bg-red-500 px-4 py-2 rounded text-white hover:bg-red-600 transition"
              disabled={loading}
            >
              Logout
            </button>
          </>
        ) : (
          <>
            <Link
              to="/login"
              className="bg-yellow-400 text-black px-4 py-2 rounded hover:bg-yellow-500 transition font-semibold"
            >
              Login
            </Link>
            <Link
              to="/register"
              className="bg-gray-800 text-white px-4 py-2 rounded border border-yellow-400 hover:bg-yellow-900 transition font-semibold"
            >
              Register
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}
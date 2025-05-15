
/*
  File: src/components/Navbar.jsx
*/
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

function Navbar() {
  const { user, loading, logout } = useAuth();

  return (
    <nav className="w-full bg-brand-dark shadow-md py-3 px-4 sm:py-4 sm:px-6 flex justify-between items-center">
      <h1 className="text-xl sm:text-2xl font-bold text-btn-primary">ChessEarn</h1>
      <div className="flex items-center space-x-2 sm:space-x-4">
        <Link to="/" className="nav-link">Home</Link>
        {user && <Link to="/bet" className="nav-link">Bet</Link>}
        {user && <Link to="/profile" className="nav-link">Profile</Link>}
        {user?.role === 'admin' && <Link to="/admin" className="nav-link">Admin</Link>}

        {!loading && !user && (
          <>
            <Link to="/login" className="btn-primary">Login</Link>
            <Link to="/register" className="btn-outline">Register</Link>
          </>
        )}

        {!loading && user && (
          <button
            onClick={logout}
            className="btn-primary hover:bg-red-600"
          >
            Logout
          </button>
        )}
      </div>
    </nav>
  );
}

export default Navbar;

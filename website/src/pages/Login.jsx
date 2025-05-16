import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

function Login() {
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();
  const location = useLocation();
  const redirectTo = new URLSearchParams(location.search).get('redirect') || '/';
  const { login } = useAuth();

  // Validate email, username, or phone
  const isValidIdentifier = (value) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    const usernameRegex = /^[a-zA-Z0-9_]{3,}$/;
    return emailRegex.test(value) || phoneRegex.test(value) || usernameRegex.test(value);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const trimmedIdentifier = identifier.trim();
    const trimmedPassword = password.trim();

    if (!trimmedIdentifier || !trimmedPassword) {
      setError('Please fill in all fields.');
      setLoading(false);
      return;
    }

    if (!isValidIdentifier(trimmedIdentifier)) {
      setError('Please enter a valid email, username, or phone number.');
      setLoading(false);
      return;
    }

    try {
      await login({ identifier: trimmedIdentifier, password: trimmedPassword });
      const safeRedirect = redirectTo.startsWith('/') && !redirectTo.includes('://') ? redirectTo : '/';
      navigate(safeRedirect, { replace: true });
    } catch (err) {
      let msg = err.error || err.message || 'An unexpected error occurred.';
      if (err.status === 401) msg = 'Invalid credentials. Please try again.';
      if (err.status === 429) msg = 'Too many attempts. Please try again later.';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-dark text-text-light flex flex-col">
      <section className="flex-grow flex items-center justify-center px-4">
        <form
          onSubmit={handleSubmit}
          className="bg-brand-dark p-6 sm:p-8 rounded-lg shadow-md w-full max-w-md border border-brand-accent/50"
          aria-labelledby="login-title"
        >
          <h2 id="login-title" className="text-2xl sm:text-3xl font-bold text-brand-accent mb-6 text-center">
            Login
          </h2>
          <div className="space-y-4">
            {error && (
              <p className="text-red-500 text-sm text-center" role="alert">{error}</p>
            )}
            <div>
              <label htmlFor="identifier" className="block text-text-light mb-1">
                Email, Username, or Phone
              </label>
              <input
                id="identifier"
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="Enter email, username, or phone"
                required
                disabled={loading}
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2 disabled:opacity-50"
              />
            </div>
            <div>
              <label htmlFor="password" className="block text-text-light mb-1">
                Password
              </label>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter password"
                  required
                  disabled={loading}
                  className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2 disabled:opacity-50"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-brand-accent"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                  disabled={loading}
                >
                  {showPassword ? 'Hide' : 'Show'}
                </button>
              </div>
            </div>
            <button
              type="submit"
              disabled={loading}
              aria-busy={loading}
              className="w-full bg-brand-accent text-brand-dark font-semibold py-2 rounded-lg hover:bg-brand-danger hover:text-text-light transition-all duration-300 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Logging in...' : 'Login'}
            </button>
          </div>
        </form>
      </section>
      <footer className="w-full bg-brand-dark py-4 text-center text-text-muted">
        <p>© 2025 ChessEarn. All rights reserved.</p>
      </footer>
    </div>
  );
}

export default Login;
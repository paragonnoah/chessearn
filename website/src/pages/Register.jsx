import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';

function Register() {
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    phone_number: '',
    password: '',
  });
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { id, value } = e.target;
    setFormData((prev) => ({ ...prev, [id]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const data = Object.fromEntries(
      Object.entries(formData).map(([k, v]) => [k, v.trim()])
    );

    // Validation
    if (Object.values(data).some((v) => !v)) {
      setError('Please fill in all fields.');
      setLoading(false);
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
      setError('Please enter a valid email address.');
      setLoading(false);
      return;
    }
    if (!/^[a-zA-Z0-9_]{3,}$/.test(data.username)) {
      setError('Username must be at least 3 characters (letters, numbers, underscores).');
      setLoading(false);
      return;
    }
    if (!/^\+\d{10,15}$/.test(data.phone_number)) {
      setError('Please enter a valid phone number with country code (e.g., +1234567890).');
      setLoading(false);
      return;
    }
    if (data.password.length < 8) {
      setError('Password must be at least 8 characters long.');
      setLoading(false);
      return;
    }

    try {
      await authService.register(data);
      navigate('/login', { replace: true });
    } catch (err) {
      let msg = err.error || err.message || 'An unexpected error occurred.';
      if (err.status === 400) msg = 'Invalid data or user already exists.';
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
          aria-labelledby="register-title"
        >
          <h2 id="register-title" className="text-2xl sm:text-3xl font-bold text-brand-accent mb-6 text-center">
            Register
          </h2>
          <div className="space-y-4">
            {error && (
              <p className="text-red-500 text-sm text-center" role="alert">{error}</p>
            )}
            {[
              { id: 'first_name', label: 'First Name', type: 'text', placeholder: 'Enter first name' },
              { id: 'last_name', label: 'Last Name', type: 'text', placeholder: 'Enter last name' },
              { id: 'email', label: 'Email', type: 'email', placeholder: 'Enter email' },
              { id: 'username', label: 'Username', type: 'text', placeholder: 'Enter username' },
              { id: 'phone_number', label: 'Phone Number', type: 'tel', placeholder: 'e.g., +254744929244' },
              { id: 'password', label: 'Password', type: 'password', placeholder: 'Enter password' },
            ].map(({ id, label, type, placeholder }) => (
              <div key={id}>
                <label htmlFor={id} className="block text-text-light mb-1">{label}</label>
                <input
                  id={id}
                  type={type}
                  value={formData[id]}
                  onChange={handleChange}
                  placeholder={placeholder}
                  required
                  disabled={loading}
                  className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2 disabled:opacity-50"
                />
              </div>
            ))}
            <button
              type="submit"
              disabled={loading}
              aria-busy={loading}
              className="w-full bg-brand-accent text-brand-dark font-semibold py-2 rounded-lg hover:bg-brand-danger hover:text-text-light transition-all duration-300 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Registering...' : 'Register'}
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

export default Register;
'use client';
import { useState, useEffect } from 'react';
import { useAuth } from '../../lib/AuthContext';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';

export default function LoginPage() {
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { login, user, loading: authLoading } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();

  // Get redirect URL from query params
  const redirectUrl = searchParams.get('redirect') || '/';

  useEffect(() => {
    if (user && !authLoading) {
      router.push(redirectUrl);
    }
  }, [user, authLoading, router, redirectUrl]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isLoading) return;

    setError('');
    setIsLoading(true);

    try {
      await login(identifier, password);
      // Redirect is handled in useEffect when user state updates
    } catch (err: any) {
      console.error('LoginPage error:', err);
      setError(err.message || 'Login failed. Please check your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  // Show loading spinner while checking auth state
  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="flex flex-col items-center space-y-4">
          <div className="w-12 h-12 border-4 border-amber-400 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-slate-400">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center text-slate-900 text-3xl font-black">
              ♔
            </div>
          </div>
          <h1 className="text-3xl font-bold text-slate-100 mb-2">Welcome Back</h1>
          <p className="text-slate-400">Sign in to your ChessEarn account</p>
        </div>

        {/* Login Form */}
        <div className="bg-slate-800/50 backdrop-blur-sm rounded-2xl border border-slate-700 p-8 shadow-2xl">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Username/Email Field */}
            <div>
              <label 
                htmlFor="identifier" 
                className="block text-sm font-medium text-slate-300 mb-2"
              >
                Username or Email
              </label>
              <input
                id="identifier"
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                className="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg text-slate-100 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all"
                placeholder="Enter your username or email"
                required
                disabled={isLoading}
              />
            </div>

            {/* Password Field */}
            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-medium text-slate-300 mb-2"
              >
                Password
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-lg text-slate-100 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all"
                placeholder="Enter your password"
                required
                disabled={isLoading}
              />
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-900/20 border border-red-800 rounded-lg p-3">
                <p className="text-red-400 text-sm flex items-center">
                  <svg className="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                  </svg>
                  {error}
                </p>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-gradient-to-r from-amber-600 to-amber-700 hover:from-amber-700 hover:to-amber-800 disabled:from-slate-600 disabled:to-slate-700 text-slate-900 font-semibold py-3 px-4 rounded-lg transition-all duration-200 shadow-lg hover:shadow-amber-900/25 disabled:cursor-not-allowed flex items-center justify-center"
            >
              {isLoading ? (
                <>
                  <div className="w-5 h-5 border-2 border-slate-900 border-t-transparent rounded-full animate-spin mr-2"></div>
                  Signing In...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          {/* Divider */}
          <div className="mt-6 text-center">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-slate-600"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-slate-800 text-slate-400">Don't have an account?</span>
              </div>
            </div>
          </div>

          {/* Register Link */}
          <div className="mt-6 text-center">
            <Link
              href={`/register?redirect=${encodeURIComponent(redirectUrl)}`}
              className="text-amber-400 hover:text-amber-300 font-medium transition-colors"
            >
              Create your account →
            </Link>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-slate-500 text-sm">
          <p>By signing in, you agree to our Terms of Service and Privacy Policy</p>
        </div>
      </div>
    </div>
  );
}
import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { profileService } from '../services/profileService';

function Profile() {
  const { user, loading: authLoading } = useAuth();
  const [photoFile, setPhotoFile] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState(null);

  // Refresh profile after upload
  const refreshProfile = async () => {
    try {
      const updated = await profileService.getProfile();
      return updated;
    } catch (err) {
      setError(err.error || 'Failed to refresh profile');
      return null;
    }
  };

  const handleFileChange = (e) => {
    if (e.target.files.length) setPhotoFile(e.target.files[0]);
  };

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!photoFile) {
      setError('Please select a photo');
      return;
    }
    setUploading(true);
    setError(null);
    try {
      await profileService.uploadPhoto(photoFile);
      const updated = await refreshProfile();
      if (updated) {
        // AuthContext user state updates automatically via loadUser
        setPhotoFile(null);
      }
    } catch (err) {
      setError(err.error || 'Photo upload failed');
    } finally {
      setUploading(false);
    }
  };

  if (authLoading) {
    return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
  }

  if (!user) {
    return null; // ProtectedRoute handles redirect
  }

  return (
    <div className="min-h-screen bg-brand-light text-brand-dark flex flex-col">
      <main className="flex-grow max-w-3xl mx-auto p-6">
        <h2 className="text-2xl font-bold mb-4">Your Profile</h2>
        {error && <p className="text-red-500 mb-4" role="alert">{error}</p>}
        <div className="space-y-4">
          <div className="flex items-center space-x-4">
            {user.photo_url ? (
              <img
                src={user.photo_url}
                alt="Profile"
                className="w-24 h-24 rounded-full object-cover"
              />
            ) : (
              <div className="w-24 h-24 bg-surface-dark rounded-full flex items-center justify-center text-text-muted">
                No Photo
              </div>
            )}
            <div className="space-y-1">
              <p><strong>ID:</strong> {user.id}</p>
              <p><strong>Name:</strong> {user.first_name} {user.last_name}</p>
              <p><strong>Email:</strong> {user.email}</p>
              <p><strong>Username:</strong> {user.username}</p>
              <p><strong>Phone:</strong> {user.phone_number}</p>
              <p><strong>Role:</strong> {user.role}</p>
              <p><strong>Ranking:</strong> {user.ranking}</p>
              <p>
                <strong>Wallet Balance:</strong>{' '}
                {user.wallet_balance != null ? `$${user.wallet_balance.toFixed(2)}` : '$0.00'}
              </p>
              <p><strong>Active:</strong> {user.is_active ? 'Yes' : 'No'}</p>
              <p><strong>Verified:</strong> {user.is_verified ? 'Yes' : 'No'}</p>
            </div>
          </div>

          <form onSubmit={handleUpload} className="space-y-2">
            <label htmlFor="photo-upload" className="block">
              Update Photo:
            </label>
            <input
              id="photo-upload"
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              disabled={uploading}
              className="block text-sm text-brand-dark file:mr-4 file:py-2 file:px-4 file:rounded-md file:bg-btn-primary file:text-text-dark file:font-semibold file:hover:bg-btn-primary-hover disabled:opacity-50"
            />
            <button
              type="submit"
              disabled={uploading || !photoFile}
              className="mt-2 bg-btn-primary hover:bg-btn-primary-hover text-text-dark font-semibold py-1 px-4 rounded-md disabled:opacity-50 disabled:cursor-not-allowed"
              aria-busy={uploading}
            >
              {uploading ? 'Uploading...' : 'Upload'}
            </button>
          </form>
        </div>
      </main>
      <footer className="w-full bg-brand-dark py-4 text-center text-text-muted">
        <p>© 2025 ChessEarn. All rights reserved.</p>
      </footer>
    </div>
  );
}

export default Profile;
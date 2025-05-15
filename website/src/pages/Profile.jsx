// src/pages/Profile.jsx
import { useState, useEffect } from 'react';
import { profileService } from '../services/profileService';

function Profile() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [photoFile, setPhotoFile] = useState(null);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const data = await profileService.getProfile();
        setProfile(data);
      } catch (err) {
        setError(err.error || err.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  const handleFileChange = (e) => {
    if (e.target.files.length) setPhotoFile(e.target.files[0]);
  };

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!photoFile) return;
    setUploading(true);
    setError(null);
    try {
      await profileService.uploadPhoto(photoFile);
      const updated = await profileService.getProfile();
      setProfile(updated);
    } catch (err) {
      setError(err.error || err.message || 'Photo upload failed');
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="min-h-screen bg-brand-light text-brand-dark flex flex-col">

      <main className="flex-grow max-w-3xl mx-auto p-6">
        <h2 className="text-2xl font-bold mb-4">Your Profile</h2>
        {loading ? (
          <p>Loading profile...</p>
        ) : error ? (
          <p className="text-red-500">{error}</p>
        ) : (
          <div className="space-y-4">
            <div className="flex items-center space-x-4">
              {profile.photo_url ? (
                <img src={profile.photo_url} alt="Profile" className="w-24 h-24 rounded-full object-cover" />
              ) : (
                <div className="w-24 h-24 bg-surface-dark rounded-full flex items-center justify-center text-text-muted">
                  No Photo
                </div>
              )}
              <div className="space-y-1">
                <p><strong>ID:</strong> {profile.id}</p>
                <p><strong>Name:</strong> {profile.first_name} {profile.last_name}</p>
                <p><strong>Email:</strong> {profile.email}</p>
                <p><strong>Username:</strong> {profile.username}</p>
                <p><strong>Phone:</strong> {profile.phone_number}</p>
                <p><strong>Role:</strong> {profile.role}</p>
                <p><strong>Ranking:</strong> {profile.ranking}</p>
                <p><strong>Wallet Balance:</strong>{' '} 
                {profile.wallet_balance != null ? `$${profile.wallet_balance.toFixed(2)}` : '0.0'}
                </p>

                <p><strong>Active:</strong> {profile.is_active ? 'Yes' : 'No'}</p>
                <p><strong>Verified:</strong> {profile.is_verified ? 'Yes' : 'No'}</p>
              </div>
            </div>

            <form onSubmit={handleUpload} className="space-y-2">
              <label className="block">Update Photo:</label>
              <input
                type="file"
                accept="image/*"
                onChange={handleFileChange}
                className="block"
              />
              <button
                type="submit"
                disabled={uploading}
                className="mt-2 bg-btn-primary hover:bg-btn-primary-hover text-text-dark font-semibold py-1 px-4 rounded-md disabled:opacity-50"
              >
                {uploading ? 'Uploading...' : 'Upload'}
              </button>
            </form>
          </div>
        )}
      </main>
      <footer className="w-full bg-brand-dark py-4 text-center text-text-muted">
        <p>© 2025 ChessEarn. All rights reserved.</p>
      </footer>
    </div>
  );
}

export default Profile;

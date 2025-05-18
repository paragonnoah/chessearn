import React, { useEffect, useState, useRef } from "react";
import { getProfile, uploadProfilePhoto, getProfilePhoto } from "../api/profile";

export default function Profile() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [photoUrl, setPhotoUrl] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState("");
  const fileInput = useRef();

  useEffect(() => {
    async function fetchProfile() {
      setLoading(true);
      try {
        const data = await getProfile();
        setProfile(data);
        if (data.photo_url && data.id) {
          fetchPhoto(data.id);
        }
      } catch (err) {
        setMessage("Failed to load profile.");
      } finally {
        setLoading(false);
      }
    }

    async function fetchPhoto(userId) {
      try {
        const blob = await getProfilePhoto(userId);
        setPhotoUrl(URL.createObjectURL(blob));
      } catch {
        setPhotoUrl(null);
      }
    }

    fetchProfile();
    // Cleanup: revoke object URL to avoid memory leaks
    return () => {
      if (photoUrl) URL.revokeObjectURL(photoUrl);
    };
    // eslint-disable-next-line
  }, []);

  const handlePhotoChange = async (event) => {
    const file = event.target.files[0];
    if (!file) return;
    setUploading(true);
    setMessage("");
    try {
      await uploadProfilePhoto(file);
      setMessage("Photo uploaded successfully!");
      // Refresh photo
      if (profile?.id) {
        const blob = await getProfilePhoto(profile.id);
        setPhotoUrl(URL.createObjectURL(blob));
      }
    } catch (err) {
      setMessage(err?.message || "Failed to upload photo.");
    } finally {
      setUploading(false);
      // Clear input value so user can upload same file again if needed
      if (fileInput.current) fileInput.current.value = "";
    }
  };

  if (loading) {
    return <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded shadow text-center">Loading profile...</div>;
  }

  if (!profile) {
    return <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded shadow text-center">No profile data found.</div>;
  }

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white rounded shadow">
      <h2 className="text-2xl font-bold mb-4">My Profile</h2>
      <div className="flex flex-col items-center mb-4">
        <div className="w-24 h-24 rounded-full overflow-hidden border mb-2 bg-gray-100 flex items-center justify-center">
          {photoUrl ? (
            <img src={photoUrl} alt="Profile" className="object-cover w-full h-full" />
          ) : (
            <span className="text-gray-400">No photo</span>
          )}
        </div>
        <input
          type="file"
          accept="image/*"
          onChange={handlePhotoChange}
          disabled={uploading}
          ref={fileInput}
          className="mb-2"
        />
        <button
          onClick={() => fileInput.current && fileInput.current.click()}
          className="bg-yellow-400 px-3 py-1 rounded text-black font-medium hover:bg-yellow-500 transition"
          disabled={uploading}
          type="button"
        >
          {uploading ? "Uploading..." : "Upload New Photo"}
        </button>
      </div>
      <div className="mb-2"><strong>Name:</strong> {profile.first_name} {profile.last_name}</div>
      <div className="mb-2"><strong>Username:</strong> {profile.username}</div>
      <div className="mb-2"><strong>Email:</strong> {profile.email}</div>
      <div className="mb-2"><strong>Phone:</strong> {profile.phone_number}</div>
      <div className="mb-2"><strong>Role:</strong> {profile.role}</div>
      <div className="mb-2"><strong>Ranking:</strong> {profile.ranking}</div>
      <div className="mb-2"><strong>Wallet:</strong> ${profile.wallet_balance}</div>
      <div className="mb-2"><strong>Status:</strong> {profile.is_active ? "Active" : "Inactive"}</div>
      <div className="mb-2"><strong>Verified:</strong> {profile.is_verified ? "Yes" : "No"}</div>
      {message && <div className="mt-4 text-center text-yellow-700">{message}</div>}
    </div>
  );
}
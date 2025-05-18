import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useNavigate, Link } from "react-router-dom";
import PhoneInput from 'react-phone-input-2';
import 'react-phone-input-2/lib/style.css';

export default function Login() {
  const { login, error } = useAuth();
  const [form, setForm] = useState({ identifier: "", password: "" });
  const [usePhoneLogin, setUsePhoneLogin] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

  const onChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const onPhoneChange = (phone) =>
    setForm({ ...form, identifier: phone });

  const onSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await login(form);
      navigate("/");
    } catch (err) {
      // Error is handled in the AuthContext
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form className="max-w-md mx-auto mt-10 p-6 bg-white rounded shadow" onSubmit={onSubmit}>
      <h2 className="text-2xl font-bold mb-4">Login</h2>
      {usePhoneLogin ? (
        <>
          <label className="block mb-2 text-sm font-medium">Phone Number</label>
          <PhoneInput
            country={'ke'}  // Default to Kenya, adjust based on your needs
            value={form.identifier}
            onChange={onPhoneChange}
            enableSearch={true}
            inputClass="w-full p-2 border rounded"
            containerClass="mb-4"
            autoComplete="tel"
          />
        </>
      ) : (
        <>
          <label className="block mb-2 text-sm font-medium">Email or Username</label>
          <input
            name="identifier"
            placeholder="Enter your email or username"
            value={form.identifier}
            onChange={onChange}
            className="w-full mb-4 p-2 border rounded"
            autoComplete="username"
          />
        </>
      )}
      <label className="block mb-2 text-sm font-medium">Password</label>
      <input
        name="password"
        type="password"
        placeholder="Enter your password"
        value={form.password}
        onChange={onChange}
        className="w-full mb-4 p-2 border rounded"
        autoComplete="current-password"
      />
      <button
        className="bg-yellow-400 text-black px-4 py-2 rounded w-full"
        disabled={submitting}
        type="submit"
      >
        {submitting ? "Logging in..." : "Login"}
      </button>
      {error && <div className="text-red-500 mt-2">{error}</div>}
      <div className="mt-4 text-sm text-center">
        {usePhoneLogin ? (
          <button type="button" onClick={() => setUsePhoneLogin(false)} className="text-yellow-600 hover:underline">
            Login with email or username instead
          </button>
        ) : (
          <button type="button" onClick={() => setUsePhoneLogin(true)} className="text-yellow-600 hover:underline">
            Login with phone number instead
          </button>
        )}
      </div>
      <div className="mt-2 text-sm text-center">
        Don't have an account?{" "}
        <Link to="/register" className="text-yellow-600 hover:underline">
          Register
        </Link>
      </div>
    </form>
  );
}
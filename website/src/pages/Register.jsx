import React, { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useNavigate, Link } from "react-router-dom";
import PhoneInput from 'react-phone-input-2';
import 'react-phone-input-2/lib/style.css';

export default function Register() {
  const { register, error } = useAuth();
  const [form, setForm] = useState({
    first_name: "",
    last_name: "",
    email: "",
    username: "",
    phone_number: "",
    password: "",
  });
  const [retypePassword, setRetypePassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [validationError, setValidationError] = useState("");
  const navigate = useNavigate();

  const onChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const onSubmit = async (e) => {
    e.preventDefault();
    if (form.password !== retypePassword) {
      setValidationError("Passwords do not match");
      return;
    }
    setValidationError("");
    setSubmitting(true);
    try {
      await register(form);
      navigate("/login");
    } catch (err) {
      // error handled in context
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form className="max-w-md mx-auto mt-10 p-6 bg-white rounded shadow" onSubmit={onSubmit}>
      <h2 className="text-2xl font-bold mb-4">Register</h2>
      <input
        name="first_name"
        placeholder="First Name"
        value={form.first_name}
        onChange={onChange}
        className="w-full mb-3 p-2 border rounded"
        autoComplete="given-name"
      />
      <input
        name="last_name"
        placeholder="Last Name"
        value={form.last_name}
        onChange={onChange}
        className="w-full mb-3 p-2 border rounded"
        autoComplete="family-name"
      />
      <input
        name="email"
        type="email"
        placeholder="Email"
        value={form.email}
        onChange={onChange}
        className="w-full mb-3 p-2 border rounded"
        autoComplete="email"
      />
      <input
        name="username"
        placeholder="Username"
        value={form.username}
        onChange={onChange}
        className="w-full mb-3 p-2 border rounded"
        autoComplete="username"
      />
      <PhoneInput
        country={'ke'}  // Default to Kenya, can be changed
        value={form.phone_number}
        onChange={(phone) => setForm({ ...form, phone_number: phone })}
        enableSearch={true}
        inputClass="w-full p-2 border rounded"
        containerClass="mb-3"
        autoComplete="tel"
      />
      <input
        name="password"
        type="password"
        placeholder="Password"
        value={form.password}
        onChange={onChange}
        className="w-full mb-3 p-2 border rounded"
        autoComplete="new-password"
      />
      <input
        type="password"
        placeholder="Retype Password"
        value={retypePassword}
        onChange={(e) => setRetypePassword(e.target.value)}
        className="w-full mb-4 p-2 border rounded"
        autoComplete="new-password"
      />
      <button
        className="bg-yellow-400 text-black px-4 py-2 rounded w-full"
        disabled={submitting}
        type="submit"
      >
        {submitting ? "Registering..." : "Register"}
      </button>
      {(validationError || error) && (
        <div className="text-red-500 mt-2">{validationError || error}</div>
      )}
      <div className="mt-4 text-sm text-center">
        Already have an account?{" "}
        <Link to="/login" className="text-yellow-600 hover:underline">
          Login
        </Link>
      </div>
    </form>
  );
}
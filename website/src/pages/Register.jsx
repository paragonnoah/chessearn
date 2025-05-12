import { useState } from 'react';
import Navbar from '../components/Navbar';

function Register() {
  return (
    <div className="min-h-screen bg-brand-dark text-text-light flex flex-col">
      <Navbar />
      <section className="flex-grow flex items-center justify-center px-4">
        <div className="bg-brand-dark p-6 sm:p-8 rounded-lg shadow-md w-full max-w-md border border-brand-accent/50">
          <h2 className="text-2xl sm:text-3xl font-bold text-brand-accent mb-6 text-center">Register</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-text-light mb-1" htmlFor="first_name">First Name</label>
              <input
                type="text"
                id="first_name"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="Enter first name"
              />
            </div>
            <div>
              <label className="block text-text-light mb-1" htmlFor="last_name">Last Name</label>
              <input
                type="text"
                id="last_name"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="Enter last name"
              />
            </div>
            <div>
              <label className="block text-text-light mb-1" htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="Enter email"
              />
            </div>
            <div>
              <label className="block text-text-light mb-1" htmlFor="username">Username</label>
              <input
                type="text"
                id="username"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="Enter username"
              />
            </div>
            <div>
              <label className="block text-text-light mb-1" htmlFor="phone_number">Phone Number (with country code)</label>
              <input
                type="tel"
                id="phone_number"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="e.g., +254744929244"
              />
            </div>
            <div>
              <label className="block text-text-light mb-1" htmlFor="password">Password</label>
              <input
                type="password"
                id="password"
                className="w-full p-2 rounded-lg bg-brand-light text-brand-dark placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-brand-accent focus:ring-offset-2"
                placeholder="Enter password"
              />
            </div>
            <button className="w-full bg-brand-accent text-brand-dark font-semibold py-2 rounded-lg hover:bg-brand-danger hover:text-text-light transition-all duration-300 transform hover:scale-105">
              Register
            </button>
          </div>
        </div>
      </section>
      <footer className="w-full bg-brand-dark py-4 text-center text-text-muted">
        <p>© 2025 ChessEarn. All rights reserved.</p>
      </footer>
    </div>
  );
}

export default Register;
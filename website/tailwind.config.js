/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Core Brand (Modern Strategy scheme)
        'brand-dark': '#0A2647',    // Dark Blue
        'brand-light': '#E8ECEF',   // Light Gray
        'brand-accent': '#2ECC71',  // Neon Green
        'brand-danger': '#C0392B',  // Deep Red
        'brand-secondary': '#3498DB', 

        // Gradients & Effects
        'brand-gradient-start': '#0A2647',
        'brand-gradient-end': '#144272',

        // Text shades
        'text-light': '#F8F9FA',
        'text-muted': '#AAB8C2',
        'text-dark': '#1C1C1E',

        // Button shades
        'btn-primary': '#2ECC71',
        'btn-primary-hover': '#27AE60',
        'btn-outline': '#FFFFFF',
        'btn-outline-hover': '#2ECC71',

        // Additional depth
        'surface-light': '#F4F4F4',
        'surface-dark': '#1B1F23',
        'border-soft': '#D1D5DB',
      },
    },
  },
  plugins: [],
}

/*
  File: src/App.jsx
  Wrap routes with AuthProvider and define ProtectedRoute logic.
*/
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';

import Navbar from './components/Navbar';
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import Profile from './pages/Profile';
import Bet from './pages/Bet';
import AdminDashboard from './pages/AdminDashboard';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Protected for any authenticated user */}
          <Route element={<ProtectedRoute />}> 
            <Route path="/profile" element={<Profile />} />
            <Route path="/bet" element={<Bet />} />
          </Route>

          {/* Admin‑only routes */}
          <Route element={<ProtectedRoute roles={["admin"]} />}> 
            <Route path="/admin" element={<AdminDashboard />} />
          </Route>

          {/* catch‑all could go here */}
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;

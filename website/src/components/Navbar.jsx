import { Link } from 'react-router-dom';

function Navbar() {
  return (
    <nav className="w-full bg-brand-dark shadow-md py-3 px-4 sm:py-4 sm:px-6 flex justify-between items-center">
      <h1 className="text-xl sm:text-2xl font-bold text-btn-primary">ChessEarn</h1>
      <div className="flex items-center space-x-2 sm:space-x-4">
        <Link 
          to="/" 
          className="text-sm sm:text-base text-text-light hover:text-btn-primary transition relative after:content-[''] after:absolute after:bottom-0 after:left-0 after:w-full after:h-0.5 after:bg-btn-primary after:scale-x-0 after:transition-transform after:duration-300 hover:after:scale-x-100 font-medium"
        >
          Home
        </Link>
        <Link 
          to="/bet" 
          className="text-sm sm:text-base text-text-light hover:text-btn-primary transition relative after:content-[''] after:absolute after:bottom-0 after:left-0 after:w-full after:h-0.5 after:bg-btn-primary after:scale-x-0 after:transition-transform after:duration-300 hover:after:scale-x-100 font-medium"
        >
          Bet
        </Link>
        <Link 
          to="/profile" 
          className="text-sm sm:text-base text-text-light hover:text-btn-primary transition relative after:content-[''] after:absolute after:bottom-0 after:left-0 after:w-full after:h-0.5 after:bg-btn-primary after:scale-x-0 after:transition-transform after:duration-300 hover:after:scale-x-100 font-medium"
        >
          Profile
        </Link>
        <Link
          to="/login"
          className="bg-btn-primary hover:bg-btn-primary-hover text-white px-4 py-2 rounded-lg transition font-medium shadow-sm transform hover:-translate-y-0.5"
        >
          Login
        </Link>
        <Link
          to="/register"
          className="border border-btn-primary text-btn-primary hover:bg-btn-primary hover:text-white px-4 py-2 rounded-lg transition font-medium shadow-sm transform hover:-translate-y-0.5"
        >
          Register
        </Link>
      </div>
    </nav>
  );
}

export default Navbar;
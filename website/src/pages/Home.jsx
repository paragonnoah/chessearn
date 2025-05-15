// src/pages/Home.jsx
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

function Home() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen bg-brand-dark text-text-light flex flex-col">
      {/* Hero Section */}
      <section className="flex-grow flex flex-col items-center justify-center text-center px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-brand-gradient-start to-brand-gradient-end">
        <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold mb-4 drop-shadow-lg">
          Challenge Your Mind,
          <br className="hidden sm:inline" />
          Bet Your Skill
        </h1>
        <p className="text-lg sm:text-xl lg:text-2xl mb-8 text-text-muted max-w-2xl">
          Join the ultimate chess betting platform. Play opponents, stake your bets, and prove your strategy reigns supreme.
        </p>
        <div className="flex flex-wrap gap-4 justify-center">
          <Link
            to="/bet"
            className="bg-btn-primary hover:bg-btn-primary-hover text-text-dark font-semibold py-2 px-6 sm:py-3 sm:px-8 rounded-lg transition-transform duration-300 transform hover:scale-105 shadow-md"
          >
            Play Random
          </Link>
          <Link
            to="/guest"
            className="bg-btn-outline hover:bg-btn-outline-hover text-brand-accent border border-btn-outline hover:border-btn-primary font-semibold py-2 px-6 sm:py-3 sm:px-8 rounded-lg transition-transform duration-300 transform hover:scale-105 shadow-md"
          >
            Play as Guest
          </Link>
        </div>
      </section>

      {/* Feature Section */}
      <section className="py-16 bg-brand-dark px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto grid gap-8 grid-cols-1 sm:grid-cols-3 text-center">
          <div className="space-y-4">
            <h3 className="text-2xl font-bold text-btn-primary">Live Games</h3>
            <p className="text-text-muted">
              Play live chess with real opponents across the globe— fast matchmaking, real stakes, endless thrills!
            </p>
          </div>
          <div className="space-y-4">
            <h3 className="text-2xl font-bold text-btn-primary">Ratings & Stats</h3>
            <p className="text-text-muted">
              Sign up to unlock your personal chess profile—track every win, level up your rating, and watch your skills soar!
            </p>
          </div>
          <div className="space-y-4">
            <h3 className="text-2xl font-bold text-btn-primary">Mobile Friendly</h3>
            <p className="text-text-muted">
              Wherever you are, your next chess game is just a tap away—beautifully built for mobile play.
            </p>
          </div>
        </div>
      </section>

      {/* Match Posting Section (Authenticated Users) */}
      {user && (
        <section className="py-16 bg-brand-light text-text-dark px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold mb-6 text-center">Open Matches</h2>
            <div className="flex justify-center mb-8">
              <Link
                to="/post-match"
                className="bg-btn-primary hover:bg-btn-primary-hover text-text-dark font-semibold py-2 px-6 rounded-lg transition-transform duration-300 transform hover:scale-105 shadow-md"
              >
                Post a Match
              </Link>
            </div>
            <ul className="space-y-4">
              {/* Placeholder list. Replace with fetched matches later */}
              <li className="p-4 bg-surface-light rounded-lg shadow-sm flex justify-between items-center">
                <span>Match #1234: Alice vs Bob</span>
                <Link to="/bet/1234" className="text-btn-primary hover:underline">Join</Link>
              </li>
              <li className="p-4 bg-surface-light rounded-lg shadow-sm flex justify-between items-center">
                <span>Match #5678: Carol vs Dave</span>
                <Link to="/bet/5678" className="text-btn-primary hover:underline">Join</Link>
              </li>
            </ul>
          </div>
        </section>
      )}

      {/* Tagline Section */}
      <section className="py-12 bg-brand-secondary bg-opacity-10 text-center px-4 sm:px-6 lg:px-8">
        <blockquote className="italic text-xl sm:text-2xl lg:text-3xl max-w-3xl mx-auto text-text-dark">
          “Challenge friends and players worldwide on ChessEarn. Log in once, keep your rating and username, and earn real rewards with every win!”
        </blockquote>
      </section>

      {/* Download & Footer */}
      <footer className="bg-brand-dark py-10 px-4 sm:px-6 lg:px-8 border-t border-border-soft">
        <div className="max-w-6xl mx-auto flex flex-col lg:flex-row justify-between items-center gap-8">
          <div className="flex flex-col items-center lg:items-start space-y-4">
            <h4 className="text-lg font-semibold">Get the App</h4>
            <div className="flex space-x-4">
              <a href="#" aria-label="Download on the App Store">
                <img src="/assets/appstore.svg" alt="App Store" className="h-10" />
              </a>
              <a href="#" aria-label="Get it on Google Play">
                <img src="/assets/playstore.svg" alt="Google Play" className="h-10" />
              </a>
            </div>
          </div>
          <div className="flex flex-col items-center lg:items-end space-y-2">
            <div className="flex space-x-4">
              <Link to="#" className="text-text-muted hover:text-text-light">Language</Link>
              <Link to="#" className="text-text-muted hover:text-text-light">Privacy Policy</Link>
              <Link to="#" className="text-text-muted hover:text-text-light">Terms of Service</Link>
            </div>
            <p className="text-text-muted text-sm">© 2025 ChessEarn. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default Home

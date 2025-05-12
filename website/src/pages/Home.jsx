import Navbar from '../components/Navbar';

function Home() {
  return (
    <div className="min-h-screen bg-brand-dark text-text-light flex flex-col">
      <Navbar />

      <section className="flex-grow flex flex-col items-center justify-center text-center px-4 sm:px-6 lg:px-8">
        <h2 className="text-3xl sm:text-5xl lg:text-6xl font-extrabold mb-6 text-btn-primary drop-shadow-lg">
          Challenge Your Mind,<br className="hidden sm:inline" /> Bet Your Skill
        </h2>

        <p className="text-xl sm:text-2xl mb-10 text-text-muted max-w-2xl">
          Join the ultimate chess betting platform. Play opponents, stake your bets, and prove your strategy reigns supreme.
        </p>

        <button className="bg-btn-primary hover:bg-btn-primary-hover text-white font-semibold py-2 px-6 sm:py-3 sm:px-10 rounded-lg transition-transform duration-300 transform hover:scale-105 shadow-md focus:ring-2 focus:ring-offset-2 focus:ring-btn-primary">
          Start Playing
        </button>
      </section>

      <footer className="w-full bg-brand-dark py-6 text-center text-text-muted border-t border-border-soft">
        <p>© 2025 ChessEarn. All rights reserved.</p>
      </footer>
    </div>
  );
}

export default Home;
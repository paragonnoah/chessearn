import React from "react";

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] px-4">
      <h1 className="text-5xl font-extrabold text-gray-900 mt-10 text-center">
        Welcome to <span className="text-yellow-400">ChessEarn</span>
      </h1>
      <p className="mt-6 text-lg text-gray-700 max-w-xl text-center">
        Where chess meets excitement. Bet on your favorite chess matches, compete with others, and earn rewards for your chess intuition!
      </p>
      <div className="mt-10">
        <a
          href="#"
          className="bg-yellow-400 text-black px-8 py-3 rounded-full font-semibold text-lg shadow hover:bg-yellow-500 transition"
        >
          Get Started
        </a>
      </div>
      <section className="mt-16 max-w-2xl text-center">
        <h2 className="text-2xl font-bold mb-4">How It Works</h2>
        <ul className="space-y-2 text-gray-600 text-left mx-auto inline-block">
          <li>• Browse ongoing and upcoming chess matches.</li>
          <li>• Place bets on your predicted winners or outcomes.</li>
          <li>• Track your bets and see live match results.</li>
          <li>• Win rewards for correct predictions!</li>
        </ul>
      </section>
    </div>
  );
}
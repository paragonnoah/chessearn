import React from "react";

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-400 py-4 text-center mt-12">
      <div>
        © {new Date().getFullYear()} ChessEarn. All rights reserved.
      </div>
      <div className="mt-2 text-xs">
        Made with <span className="text-yellow-400">♟️</span> and React.
      </div>
    </footer>
  );
}
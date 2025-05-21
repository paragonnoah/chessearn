# ChessEarn Mobile App

A monetized multiplayer chess platform allowing players to compete in real-time 1v1 matches with betting, rankings, and financial features such as deposits, withdrawals, and transaction tracking.

## 🚀 Project Overview

**ChessEarn** is a competitive chess mobile application developed with Flutter, integrated with a Flask backend and PostgreSQL database. It supports real-time gameplay, betting systems, rankings, friend features, and financial operations (Stripe, M-Pesa, PayPal).

---

## 🧩 Features

* ✅ Real-time 1v1 online chess with WebSocket support
* ✅ User registration, login, and token-based authentication
* ✅ Betting system (with 5% house fee)
* ✅ Stripe, M-Pesa, PayPal payment integration
* ✅ Game history and match stats (PGN)
* ✅ Leaderboards and player rankings
* ✅ Friends system with online status
* ✅ Profile management and photo uploads
* ✅ Localization (English, Swahili, Spanish)
* ✅ User dashboard with transaction history

---

## 🛠️ Tech Stack

| Area     | Tech Used                   |
| -------- | --------------------------- |
| Frontend | Flutter                     |
| Backend  | Python (Flask)              |
| Realtime | WebSocket (Flask-SocketIO)  |
| Payments | Stripe, M-Pesa, PayPal APIs |
| Database | PostgreSQL                  |
| Infra    | AWS / Cloudflare            |

---

## 📅 Project Timeline

**Development Period:** May 21, 2025 – July 23, 2025
**Current Phase:** ✅ Phase 2 (Authentication, Online Play, Rankings)

### 🧱 Phases Breakdown

1. **Phase 1**: Project Setup & Chessboard UI ✅
2. **Phase 2**: Authentication, Online 1v1, Rankings, Friends, Profiles *(May 21 - Jun 11)*
3. **Phase 3**: Payments, Betting, Game History *(Jun 12 - Jun 25)*
4. **Phase 4**: Dashboard, Localization, Optimization *(Jun 26 - Jul 9)*
5. **Phase 5**: Global Testing & Deployment *(Jul 10 - Jul 23)*

---

## 🧪 Testing Strategy

* Emulator and physical device tests
* VPN regional testing (US, EU, Kenya)
* Payment gateway sandbox testing (Stripe, M-Pesa)
* Real-time gameplay sync testing between devices
* Performance profiling on low-end devices

---

## 💵 Monetization

* Users place bets before matches (\$1-\$10)
* Winner receives bet minus 5% platform fee
* Deposit methods: Stripe, M-Pesa, PayPal
* Withdrawals supported for Stripe & M-Pesa

---

## 🔐 Security

* JWT authentication with secure token storage
* WebSocket connections protected via auth headers
* Input validation on both frontend and backend
* Payment APIs use secure credential storage (env vars)

---

## 🌐 Localization

Currently supported languages:

* English
* Swahili
* Spanish

---

## 📂 Folder Structure (Planned)

```
/lib
  /screens
    - login.dart
    - register.dart
    - home.dart
    - game.dart
    - more_screen.dart
  /services
    - api_service.dart
  /models
    - user.dart
    - game.dart
  /utils
    - constants.dart
    - localization.dart
/backend
  /routes
  /models
  /controllers
  app.py
```

---

## 🛣️ Roadmap Highlights

* [x] Real-time 1v1 gameplay
* [x] User authentication
* [x] Stripe integration
* [ ] M-Pesa withdrawal implementation
* [ ] Dashboard polishing
* [ ] Final deployment & store submission

---

## 🤝 Contributors

* Noah Mugaya — [LinkedIn](https://www.linkedin.com/in/noah-mugaya-330012198) | [GitHub](https://github.com/paragonnoah)

---

## 📩 Contact

Email: [paragonnoah@gmail.com](mailto:paragonnoah@gmail.com)
Telegram: [@G0D\_of\_CONFIG](https://t.me/G0D_of_CONFIG)

---

## 📜 License

This project is under development and not yet open-sourced.

---

> *Built with love and logic to make chess profitable and competitive.*

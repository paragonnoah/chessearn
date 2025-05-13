ChessEarn/
├── mobile/               # Flutter app for Android
│   ├── android/          # Android-specific configurations
│   ├── lib/
│   │   ├── main.dart     # App entry point
│   │   ├── screens/      # Screen widgets
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── game_screen.dart
│   │   ├── models/       # Data models
│   │   │   ├── user.dart
│   │   ├── services/     # API service
│   │   │   ├── api_service.dart
│   │   ├── utils/        # Utilities
│   │   │   ├── constants.dart
│   ├── pubspec.yaml      # Dependencies
├── backend/              # Flask backend
│   ├── app/
│   │   └── main.py       # Flask app
├── admin/                # React admin (your web progress)
│   ├── src/
│   │   └── App.tsx
└── README.md
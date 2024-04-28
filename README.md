# Online Chess Game
This is a scalable online multiplayer chess game (in development) built with Flutter and Node.js. You can play on the web using this [link](https://chess.manangandhi.tech/) or download the Android APK from [here](https://github.com/MananGandhi1810/online-chess/raw/app-release/app-release.apk).

## Technologies
- Flutter
- Node.js
- Express.js
- Socket.io
- PostgreSQL (Supabase)
- Prisma ORM
- Redis (Storage and Pub/Sub)
- Resend (Email service)
- Stockfish-Docker (Optional - [stockfish-docker](https://github.com/samuraitruong/stockfish-docker))

## Features
- Completed
    - User Authentication
    - Email Verification
    - Game Room Creation
    - Game Room Joining
    - Real-time Chess Game
    - Move History
    - Mobile and Web Support
    - Move Validation
    - Checkmate Detection
    - Stalemate Detection
    - Draw Detection
    - Resignation
    - Game Caching (Redis)
    - Disconnection Detection
    - Game History
    - View Past Games
    - Game Analysis using Stockfish (Deployed using [stockfish-docker](https://github.com/samuraitruong/stockfish-docker)) (Disabled on website and app due to server failure)
    - Reactions
- Planned
    - User Profile Viewing
    - Game Room Chat
    - Elo Rating System
    - In App Updates (Android)

## Installation
1. Clone the repository
2. Install the dependencies
    - Flutter
    - Node.js
    - PostgreSQL (with Supabase)
    - Redis (preferably with Docker)
3. Rename the .env file in the server directory to .env.local and fill in the required environment variables
4. Edit server urls in the `lib/constants.dart` file
5. Run the server
    ```bash
    cd server
    npm install
    npm run dev
    ```
6. Run the client
    ```bash
    flutter pub get
    flutter run
    ```
7. Enjoy, and feel free to contribute through issues and pull requests!
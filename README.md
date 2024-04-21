# Online Chess Game
This is a scalable online multiplayer chess game (in development) built with Flutter and Node.js.

## Technologies
- Flutter
- Node.js
- Express.js
- Socket.io
- PostgreSQL (Supabase)
- Prisma ORM
- Redis (Storage and Pub/Sub)
- Resend (Email service)

## Features
- Completed
    - User Authentication
    - Email Verification
    - Game Room Creation (Backend)
    - Game Room Joining (Backend)
    - Real-time Chess Game (Backend)
    - Game Room Creation (Frontend)
    - Game Room Joining (Frontend)
    - Real-time Chess Game (Frontend)
    - Move History
- Planned
    - User Profile Viewing
    - Game Room Chat
    - Game Room Settings
    - Elo Rating System

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
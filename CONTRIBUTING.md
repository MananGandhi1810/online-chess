# Contributing to online-chess
## Project setup
In order to contribute to this project, you must follow the following steps:
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

## Contribution Guidelines
1. Fork the repository
2. Create a new branch
3. Clone the repositories locally
4. Make changes
5. Commit changes
6. Push changes to your fork
7. Create a pull request

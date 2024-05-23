import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/player_data_provider.dart';
import 'components/desktop_game_layout.dart';
import 'components/mobile_game_layout.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final ChessBoardController _chessBoardController = ChessBoardController();
  bool _gameStartRequested = true;
  UserModel? opponent;
  bool _gameOver = false;

  @override
  Widget build(BuildContext context) {
    String gameState = context.watch<GameProvider>().game?.boardState ?? "";
    String userColor = "";
    List moves = context.watch<GameProvider>().game?.moves ?? [];
    if (gameState.isNotEmpty) {
      _chessBoardController.loadFen(gameState);
      userColor = context.watch<GameProvider>().game?.whitePlayerUserId ==
              context.read<AuthProvider>().user?.id
          ? "w"
          : "b";
    }
    bool hasGameStarted = context.watch<GameProvider>().hasGameStarted;
    if (hasGameStarted) {
      if (opponent == null && context.watch<GameProvider>().game != null) {
        String opponentPlayerId =
            context.watch<GameProvider>().game!.whitePlayerUserId ==
                    context.read<AuthProvider>().user?.id
                ? context.watch<GameProvider>().game!.blackPlayerUserId
                : context.watch<GameProvider>().game!.whitePlayerUserId;
        context
            .read<PlayerDataProvider>()
            .getPlayerData(opponentPlayerId)
            .then((value) {
          setState(() {
            opponent = value;
          });
        });
      }
      if (_gameStartRequested) {
        setState(() {
          _gameStartRequested = false;
        });
      }
    }
    if (context.watch<GameProvider>().game != null &&
        context.watch<GameProvider>().game?.status != "In Progress" &&
        !_gameOver) {
      debugPrint(
          "${context.watch<GameProvider>().game}, ${context.watch<GameProvider>().game?.status}, $_gameOver");
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Game Over"),
              content: Text(
                  "Winner: ${context.watch<GameProvider>().game?.winnerId == context.read<AuthProvider>().user?.id ? "You" : "Opponent"}, by ${context.watch<GameProvider>().game?.result}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      context.read<GameProvider>().resetGame();
                    });
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    }
    if (!hasGameStarted && !_gameStartRequested && !_gameOver) {
      setState(() {
        _gameOver = true;
      });
    }
    return Scaffold(
      body: hasGameStarted
          ? MediaQuery.of(context).size.width > 600
              ? DesktopGameLayout(
                  chessBoardController: _chessBoardController,
                  userColor: userColor,
                  moves: moves,
                  opponent: opponent,
                )
              : MobileGameLayout(
                  chessBoardController: _chessBoardController,
                  userColor: userColor,
                  moves: moves,
                  opponent: opponent,
                )
          : !hasGameStarted && _gameOver
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Game Over. Do you want to play again?"),
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameProvider>().startGame();
                          setState(() {
                            _gameOver = false;
                            _gameStartRequested = true;
                          });
                        },
                        child: const Text("Play Again"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No, Go Back to Home"),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Waiting for an opponent to connect..."),
                    ],
                  ),
                ),
    );
  }
}

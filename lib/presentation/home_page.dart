import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:online_chess/presentation/splash_page.dart';
import 'package:online_chess/providers/game_provider.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChessBoardController _chessBoardController = ChessBoardController();
  bool _gameStartRequested = false;

  @override
  Widget build(BuildContext context) {
    String gameState = context.watch<GameProvider>().game?.boardState ?? "";
    String userColor = "";
    String turn = "";
    List moves = context.watch<GameProvider>().game?.moves ?? [];
    if (gameState.isNotEmpty) {
      _chessBoardController.loadFen(gameState);
      userColor = context.watch<GameProvider>().game?.whitePlayerUserId ==
              context.read<AuthProvider>().user?.id
          ? "w"
          : "b";
      turn =
          context.watch<GameProvider>().game!.moves.length % 2 == 0 ? "w" : "b";
    }
    bool hasGameStarted = context.watch<GameProvider>().hasGameStarted;
    if (hasGameStarted) {
      if (_gameStartRequested) {
        setState(() {
          _gameStartRequested = false;
        });
      }
    }
    if (context.watch<GameProvider>().game != null &&
        context.watch<GameProvider>().game?.status != "In Progress") {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Game Over"),
              content: Text(
                  "Winner: ${context.watch<GameProvider>().game?.winnerId == context.read<AuthProvider>().user?.id ? "You" : "Opponent"}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<GameProvider>().resetGame();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplashPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: hasGameStarted
          ? Column(
              children: [
                Text("Your color: ${userColor == "w" ? "White" : "Black"}"),
                Expanded(
                  child: ChessBoard(
                    controller: _chessBoardController,
                    enableUserMoves: userColor == turn,
                    boardOrientation: userColor == "w"
                        ? PlayerColor.white
                        : PlayerColor.black,
                    onMove: () {
                      Move move = _chessBoardController.game.history.last.move;
                      String movestr = "";
                      if (move.piece.name.toLowerCase()[0] == "p") {
                        movestr = "${move.fromAlgebraic}${move.toAlgebraic}";
                      } else {
                        movestr =
                            "${move.piece.name[0].toUpperCase()}${move.fromAlgebraic[0]}${move.toAlgebraic}";
                      }
                      if (move.promotion != null) {
                        movestr += move.promotion!.toUpperCase();
                      }
                      if (move.captured != null) {
                        movestr = "${movestr[0]}x${movestr.substring(1)}";
                      }
                      if (move.fromAlgebraic == "e1" &&
                          move.toAlgebraic == "g1") {
                        movestr = "O-O";
                      }
                      if (move.fromAlgebraic == "e1" &&
                          move.toAlgebraic == "c1") {
                        movestr = "O-O-O";
                      }
                      if (move.fromAlgebraic == "e8" &&
                          move.toAlgebraic == "g8") {
                        movestr = "O-O";
                      }
                      if (move.fromAlgebraic == "e8" &&
                          move.toAlgebraic == "c8") {
                        movestr = "O-O-O";
                      }
                      context.read<GameProvider>().makeMove(movestr);
                    },
                  ),
                ),
              ],
            )
          : _gameStartRequested
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GameProvider>().startGame();
                      setState(() {
                        _gameStartRequested = true;
                      });
                    },
                    child: const Text("Start Game"),
                  ),
                ),
    );
  }
}

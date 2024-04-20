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
      body: context.watch<GameProvider>().hasGameStarted
          ? Center(
              child: ChessBoard(
                controller: _chessBoardController,
                enableUserMoves: userColor == turn,
                boardOrientation:
                    userColor == "w" ? PlayerColor.white : PlayerColor.black,
                onMove: () {
                  debugPrint(
                      "${_chessBoardController.game.history.last.move.fromAlgebraic}, ${_chessBoardController.game.history.last.move.toAlgebraic}, ${_chessBoardController.game.history.last.move.piece.name}");
                  Move move = _chessBoardController.game.history.last.move;
                  String movestr = "";
                  if (move.piece.name.toLowerCase()[0] == "p") {
                    movestr = "${move.fromAlgebraic}${move.toAlgebraic}";
                  } else {
                    movestr =
                        "${move.piece.name[0].toUpperCase()}${move.toAlgebraic}";
                  }
                  if (move.promotion != null) {
                    movestr += move.promotion!.toUpperCase();
                  }
                  if (move.captured != null) {
                    movestr = "${movestr[0]}x${movestr.substring(1)}";
                  }
                  context.read<GameProvider>().makeMove(movestr);
                },
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<GameProvider>().startGame();
                },
                child: const Text("Start Game"),
              ),
            ),
    );
  }
}

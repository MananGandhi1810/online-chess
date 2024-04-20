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
                size: MediaQuery.of(context).size.width,
                onMove: () {
                  debugPrint(
                      "${_chessBoardController.game.history.last.move.fromAlgebraic}, ${_chessBoardController.game.history.last.move.toAlgebraic}, ${_chessBoardController.game.history.last.move.piece.name}");
                  Move move = _chessBoardController.game.history.last.move;
                  context.read<GameProvider>().makeMove(
                      "${move.piece.name.toLowerCase() != 'p' ? move.piece.name.toUpperCase() : ''}${move.toAlgebraic}");
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

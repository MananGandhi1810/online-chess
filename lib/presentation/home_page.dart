import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:online_chess/models/user_model.dart';
import 'package:online_chess/presentation/splash_page.dart';
import 'package:online_chess/providers/game_provider.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'components/desktop_game_layout.dart';
import 'components/mobile_home_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChessBoardController _chessBoardController = ChessBoardController();
  bool _gameStartRequested = false;
  UserModel? opponent;

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
      if (opponent == null && context.watch<GameProvider>().game != null) {
        String opponentPlayerId =
            context.watch<GameProvider>().game!.whitePlayerUserId ==
                    context.read<AuthProvider>().user?.id
                ? context.watch<GameProvider>().game!.blackPlayerUserId
                : context.watch<GameProvider>().game!.whitePlayerUserId;
        context.read<GameProvider>().getPlayer(opponentPlayerId).then((value) {
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
        context.watch<GameProvider>().game?.status != "In Progress") {
      Future.delayed(Duration.zero, () {
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
          ? MediaQuery.of(context).size.width > 600
              ? DesktopGameLayout(
                  chessBoardController: _chessBoardController,
                  userColor: userColor,
                  turn: turn,
                  moves: moves,
                  opponent: opponent,
                )
              : MobileGameLayout(
                  chessBoardController: _chessBoardController,
                  userColor: userColor,
                  turn: turn,
                  moves: moves,
                  opponent: opponent,
                )
          : _gameStartRequested
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Waiting for an opponent to connect..."),
                    ],
                  ),
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

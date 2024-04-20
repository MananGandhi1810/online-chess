import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:online_chess/models/user_model.dart';
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
                    Future.delayed(Duration(milliseconds: 100), () {
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
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      opponent != null
                          ? ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(opponent!.name),
                              subtitle: Text(opponent!.email),
                            )
                          : const ListTile(
                              leading: CircularProgressIndicator(),
                            ),
                      Expanded(
                        child: ChessBoard(
                          controller: _chessBoardController,
                          enableUserMoves: userColor == turn,
                          boardOrientation: userColor == "w"
                              ? PlayerColor.white
                              : PlayerColor.black,
                          onMove: () {
                            Move move =
                                _chessBoardController.game.history.last.move;
                            String movestr = "";
                            if (move.piece.name.toLowerCase()[0] == "p") {
                              movestr =
                                  "${move.fromAlgebraic}${move.toAlgebraic}";
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
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text(
                        "Moves",
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: (moves.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(moves[index * 2]),
                                  (index * 2) + 1 < moves.length
                                      ? Text(" ${moves[(index * 2) + 1]}")
                                      : const SizedBox(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Resign Game"),
                                content: const Text(
                                    "Are you sure you want to resign the game?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<GameProvider>().resignGame();
                                    },
                                    child: const Text("Resign"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.flag),
                        label: const Text("Resign"),
                      ),
                    ],
                  ),
                ),
              ],
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

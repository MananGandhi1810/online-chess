import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:online_chess/models/user_model.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';

class DesktopGameLayout extends StatefulWidget {
  const DesktopGameLayout({
    super.key,
    required this.chessBoardController,
    required this.userColor,
    required this.moves,
    required this.opponent,
    this.isPastGame = false,
    this.onMoveSelected,
    this.suggestedMove,
  });

  final ChessBoardController chessBoardController;
  final String userColor;
  final List moves;
  final UserModel? opponent;
  final bool isPastGame;
  final void Function(int)? onMoveSelected;
  final List? suggestedMove;

  @override
  State<DesktopGameLayout> createState() => _DesktopGameLayoutState();
}

class _DesktopGameLayoutState extends State<DesktopGameLayout> {
  late ChessBoardController _chessBoardController;
  late String userColor;
  late List moves;
  String turn = '';
  late UserModel? opponent;
  bool isPastGame = false;
  List? suggestedMove = [];

  @override
  void initState() {
    setState(() {
      isPastGame = widget.isPastGame;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _chessBoardController = widget.chessBoardController;
    userColor = widget.userColor;
    moves = widget.moves;
    opponent = widget.opponent;
    turn = moves.length % 2 == 0 ? "w" : "b";
    suggestedMove = widget.suggestedMove;
    return Row(
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
                      subtitle: Text(opponent!.username),
                    )
                  : const ListTile(
                      leading: CircularProgressIndicator(),
                    ),
              Expanded(
                child: ChessBoard(
                  controller: _chessBoardController,
                  enableUserMoves: userColor == turn && !isPastGame,
                  boardOrientation:
                      userColor == "w" ? PlayerColor.white : PlayerColor.black,
                  arrows: suggestedMove != null && suggestedMove?.length == 2
                      ? [
                          BoardArrow(
                            from: suggestedMove![0],
                            to: suggestedMove![1],
                          )
                        ]
                      : [],
                  onMove: () {
                    if (isPastGame) {
                      return;
                    }
                    Move move = _chessBoardController.game.history.last.move;
                    String movestr = "";
                    debugPrint(
                        "${move.piece.name} ${move.fromAlgebraic} ${move.toAlgebraic}");
                    if (move.piece.name.toLowerCase()[0] == "p") {
                      movestr = "${move.fromAlgebraic}${move.toAlgebraic}";
                    } else {
                      movestr =
                          "${move.piece.name[0].toUpperCase()}${move.fromAlgebraic}${move.toAlgebraic}";
                    }
                    if (move.promotion != null) {
                      movestr += move.promotion!.toUpperCase();
                    }
                    if (move.captured != null) {
                      debugPrint("Captured: ${move.captured}, move: $movestr");
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (widget.onMoveSelected != null) {
                                  widget.onMoveSelected!(index * 2);
                                }
                              },
                              child: Text(
                                moves[index * 2],
                              ),
                            ),
                            (index * 2) + 1 < moves.length
                                ? TextButton(
                                    onPressed: () {
                                      if (widget.onMoveSelected != null) {
                                        widget.onMoveSelected!((index * 2) + 1);
                                      }
                                    },
                                    child: Text(" ${moves[(index * 2) + 1]}"),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                isPastGame
                    ? Container()
                    : ElevatedButton.icon(
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
        ),
      ],
    );
  }
}

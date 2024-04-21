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
    required this.turn,
    required this.moves,
    required this.opponent,
  });

  final ChessBoardController chessBoardController;
  final String userColor;
  final String turn;
  final List moves;
  final UserModel? opponent;

  @override
  State<DesktopGameLayout> createState() => _DesktopGameLayoutState();
}

class _DesktopGameLayoutState extends State<DesktopGameLayout> {
  late ChessBoardController _chessBoardController;
  late String userColor;
  late String turn;
  late List moves;
  late UserModel? opponent;

  @override
  void initState() {
    setState(() {
      _chessBoardController = widget.chessBoardController;
      userColor = widget.userColor;
      turn = widget.turn;
      moves = widget.moves;
      opponent = widget.opponent;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  enableUserMoves: userColor == turn,
                  boardOrientation:
                      userColor == "w" ? PlayerColor.white : PlayerColor.black,
                  onMove: () {
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
    );
  }
}

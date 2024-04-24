import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:online_chess/repositories/game_eval_repository.dart';
import 'package:provider/provider.dart';

import '../models/game_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'components/desktop_game_layout.dart';
import 'components/mobile_home_layout.dart';

class PastGamePage extends StatefulWidget {
  const PastGamePage({super.key, required this.game, this.opponent});

  final GameModel game;
  final UserModel? opponent;

  @override
  State<PastGamePage> createState() => _PastGamePageState();
}

class _PastGamePageState extends State<PastGamePage> {
  GameEvalRepository _gameEvalRepository = GameEvalRepository();
  final ChessBoardController _chessBoardController = ChessBoardController();
  UserModel? opponent;
  String userColor = '';
  List moves = [];
  int selectedMoveNum = 0;

  void evaluateMove() async {
    String fen = _chessBoardController.getFen();
    debugPrint(fen);
    try {
      await _gameEvalRepository.getEvaluation(fen);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void onMoveSelected(int updatedMoveNum) {
    if (updatedMoveNum < selectedMoveNum) {
      _chessBoardController
          .loadFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
      for (int i = 0; i <= updatedMoveNum; i++) {
        _chessBoardController.makeMoveWithNormalNotation(moves[i]);
        setState(() {
          selectedMoveNum = updatedMoveNum;
        });
      }
    } else if (updatedMoveNum > selectedMoveNum) {
      for (int i = selectedMoveNum; i <= updatedMoveNum; i++) {
        _chessBoardController.makeMoveWithNormalNotation(moves[i]);
        setState(() {
          selectedMoveNum = updatedMoveNum;
        });
      }
    }
    // evaluateMove();
  }

  @override
  void initState() {
    setState(() {
      moves = widget.game.moves;
      opponent = widget.opponent;
      selectedMoveNum = moves.length - 1;
      _chessBoardController.loadFen(widget.game.boardState);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userColor =
        widget.game.whitePlayerUserId == context.read<AuthProvider>().user?.id
            ? "w"
            : "b";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Analysis"),
      ),
      body: MediaQuery.of(context).size.width > 600
          ? DesktopGameLayout(
              chessBoardController: _chessBoardController,
              userColor: userColor,
              moves: moves,
              opponent: opponent,
              onMoveSelected: onMoveSelected,
            )
          : MobileGameLayout(
              chessBoardController: _chessBoardController,
              userColor: userColor,
              moves: moves,
              opponent: opponent,
              onMoveSelected: onMoveSelected,
            ),
    );
  }
}

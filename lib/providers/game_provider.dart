import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:online_chess/models/user_model.dart';
import 'package:online_chess/repositories/game_repository.dart';

import '../models/game_model.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  GameModel? _game;
  GameRepository _gameRepository = GameRepository();
  StorageService _storageService = StorageService();

  bool get hasGameStarted => _game != null && _game!.status == "In Progress";

  GameModel? get game => _game;

  void onGameStarted(dynamic data) {
    Map<String, dynamic> gameData = jsonDecode(data);
    _game = GameModel.fromJson(gameData);
    debugPrint(_game?.toJson().toString());
    _gameRepository.onMoveMade(onMoveMade);
    notifyListeners();
  }

  void onMoveMade(dynamic data) {
    Map<String, dynamic> gameData = jsonDecode(data);
    _game = GameModel.fromJson(gameData);
    debugPrint(_game?.toJson().toString());
    notifyListeners();
  }

  void makeMove(String move) {
    _gameRepository.makeMove(move);
  }

  Future<void> startGame() async {
    resetGame();
    try {
      String? data = await _storageService.read("user");
      debugPrint(data);
      if (data == null) {
        return;
      }
      String token = jsonDecode(data)['token'];
      if (token.isEmpty) {
        return;
      }
      _gameRepository.startGame(token, onGameStarted);
    } catch (e) {
      rethrow;
    }
  }

  void resetGame() {
    _game = null;
    notifyListeners();
  }

  void resignGame() {
    _gameRepository.makeMove("resign");
    notifyListeners();
  }
}

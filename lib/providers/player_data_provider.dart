import 'package:flutter/material.dart';
import 'package:online_chess/repositories/player_data_repository.dart';

import '../models/game_model.dart';
import '../models/user_model.dart';

class PlayerDataProvider extends ChangeNotifier {
  Map<String, UserModel> _playerData = {};
  Map<String, List<GameModel>> _playerGames = {};
  final PlayerDataRepository _playerDataRepository = PlayerDataRepository();

  Map<String, UserModel> get playerData => _playerData;
  Map<String, List<GameModel>> get playerGames => _playerGames;

  Future<UserModel> getPlayerData(String userId) async {
    try {
      if (_playerData.containsKey(userId)) {
        return _playerData[userId]!;
      }
      Map<String, dynamic> playerData =
          await _playerDataRepository.getPlayerData(userId);
      debugPrint(playerData.toString());
      _playerData[userId] = UserModel.fromJson(playerData);
      notifyListeners();
      return _playerData[userId]!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<GameModel>> getPlayerGames(String userId) async {
    try {
      if (_playerGames.containsKey(userId)) {
        return _playerGames[userId]!;
      }
      Map<String, dynamic> playerGames =
          await _playerDataRepository.getPlayerGames(userId);
      _playerGames[userId] = [];
      playerGames.forEach((key, value) {
        _playerGames[key]?.add(GameModel.fromJson(value));
      });
      notifyListeners();
      return _playerGames[userId]!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

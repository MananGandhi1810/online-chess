import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_chess/repositories/player_data_repository.dart';
import 'package:online_chess/services/storage_service.dart';

import '../models/game_model.dart';
import '../models/user_model.dart';

class PlayerDataProvider extends ChangeNotifier {
  final Map<String, UserModel> _playerData = {};
  final Map<String, List<GameModel>> _playerGames = {};
  final PlayerDataRepository _playerDataRepository = PlayerDataRepository();
  final StorageService _storageService = StorageService();

  Map<String, UserModel> get playerData => _playerData;
  Map<String, List<GameModel>> get playerGames => _playerGames;

  Future<UserModel> getPlayerData(String userId) async {
    try {
      if (_playerData.containsKey(userId)) {
        return _playerData[userId]!;
      }
      String token =
          jsonDecode(await _storageService.read("user") ?? "")["token"];
      Map<String, dynamic> playerData =
          await _playerDataRepository.getPlayerData(userId, token);
      _playerData[userId] = UserModel.fromJson(playerData);
      return _playerData[userId]!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<GameModel>> getPlayerGames(
      String userId, bool forceRefresh) async {
    try {
      if (_playerGames.containsKey(userId) && !forceRefresh) {
        return _playerGames[userId]!;
      }
      String token =
          jsonDecode(await _storageService.read("user") ?? "")["token"];
      List playerGames =
          await _playerDataRepository.getPlayerGames(userId, token);
      debugPrint(playerGames.toString());
      _playerGames[userId] = [];
      List<Future<List<UserModel>>> playerLoaders = [];
      for (var game in playerGames) {
        playerLoaders.add(Future.wait([
          getPlayerData(game['whiteUser']),
          getPlayerData(game['blackUser'])
        ]));
      }
      await Future.wait(playerLoaders).then((games) {
        for (int i = 0; i < playerGames.length; i++) {
          debugPrint(games[i][0].toJson().toString());
          debugPrint(games[i][1].toJson().toString());
          playerGames[i]['whitePlayer'] = games[i][0].toJson();
          playerGames[i]['blackPlayer'] = games[i][1].toJson();
        }
      });
      _playerGames[userId] =
          playerGames.map((game) => GameModel.fromJson(game)).toList();
      notifyListeners();
      return _playerGames[userId]!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<Map>> searchUsername(String username) async {
    try {
      String token =
          jsonDecode(await _storageService.read("user") ?? "")["token"];
      List<Map> searchResults =
          await _playerDataRepository.searchUsername(username, token);
      return searchResults;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

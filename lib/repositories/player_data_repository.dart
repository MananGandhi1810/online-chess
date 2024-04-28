import 'package:online_chess/services/network_service.dart';

import '../constants.dart';

class PlayerDataRepository {
  final NetworkService _networkService = NetworkService();
  String baseUrl = Constants.httpBaseUrl;

  Future<List> getPlayerGames(String playerId, String token) async {
    try {
      Map<String, dynamic> response = await _networkService
          .get('$baseUrl/getUserGames?id=$playerId', token: token);
      if (!response['success']) {
        throw Exception(response['message']);
      }
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlayerData(
      String userId, String token) async {
    try {
      Map<String, dynamic> data = await _networkService
          .get('$baseUrl/getUserData?id=$userId', token: token);
      if (!data['success']) {
        throw Exception(data['message']);
      }
      return data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map>> searchUsername(String username, String token) async {
    try {
      Map response = await _networkService
          .get('$baseUrl/searchUser?username=$username', token: token);
      if (!response['success']) {
        throw response['message'];
      }
      List<Map> res = (response['data'] as List).map((d) => d as Map).toList();
      return res;
    } catch (e) {
      rethrow;
    }
  }
}

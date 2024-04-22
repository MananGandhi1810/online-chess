import 'package:online_chess/services/network_service.dart';

import '../constants.dart';

class PlayerDataRepository {
  final NetworkService _networkService = NetworkService();
  String baseUrl = Constants.httpBaseUrl;

  Future<Map<String, String>> getPlayerGames(String playerId) async {
    try {
      Map<String, dynamic> response = await _networkService.get('$baseUrl/getUserGames?id=$playerId');
      if (!response['success']) {
        throw Exception(response['message']);
      }
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlayerData(String userId) async {
    try {
      Map<String, dynamic> data = await _networkService.get('$baseUrl/getUserData?id=$userId');
      if (!data['success']) {
        throw Exception(data['message']);
      }
      return data['data'];
    } catch (e) {
      rethrow;
    }
  }
}
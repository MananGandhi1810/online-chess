import 'package:flutter/foundation.dart';
import 'package:online_chess/constants.dart';
import 'package:online_chess/services/network_service.dart';

class GameEvalRepository {
  NetworkService _networkService = NetworkService();

  Future<Map> getEvaluation(String fen) async {
    try {
      Map response = await _networkService
          .get("${Constants.stockfishBaseUrl}/bestmove?fen=$fen");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

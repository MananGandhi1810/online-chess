import 'package:flutter/material.dart';
import 'package:online_chess/services/network_service.dart';
import 'package:online_chess/services/socket_service.dart';

class GameRepository {
  final SocketService _socketService = SocketService();
  final NetworkService _networkService = NetworkService();
  final String httpBaseUrl = 'https://0e01-2401-4900-1c96-2751-c564-25dd-b4db-4672.ngrok-free.app';
  final String baseUrl = 'http://localhost:4000/';

  void startGame(String token, dynamic Function(dynamic) onGameStarted) async {
    try {
      _socketService.connect(baseUrl);
      while (!_socketService.isConnected) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      _socketService.emit('create-game', {"token": token});
      _socketService.on('game-start', onGameStarted);
    } catch (e) {
      rethrow;
    }
  }

  void onMoveMade(dynamic Function(dynamic) onMoveMade) {
    _socketService.on('game-update', onMoveMade);
  }

  void makeMove(String move) {
    _socketService.emit('move', {"move": move});
  }

  Future<Map<String, dynamic>> getPlayer(String userId) async {
    try {
      Map<String, dynamic> data = await _networkService.get('$httpBaseUrl/getUserData?id=$userId');
      if (!data['success']) {
        throw Exception(data['message']);
      }
      return data['data'];
    } catch (e) {
      rethrow;
    }
  }
}

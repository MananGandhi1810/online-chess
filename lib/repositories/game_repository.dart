import 'package:online_chess/services/socket_service.dart';

import '../constants.dart';

class GameRepository {
  final SocketService _socketService = SocketService();
  final String httpBaseUrl = Constants.httpBaseUrl;
  final String baseUrl = Constants.socketBaseUrl;

  void startGame(String token, dynamic Function(dynamic) onGameStarted) async {
    try {
      _socketService.connect(baseUrl);
      while (!_socketService.isConnected) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _socketService.emit('create-game', {"token": token});
      _socketService.on('game-start', onGameStarted);
    } catch (e) {
      rethrow;
    }
  }

  void onReact(dynamic Function(dynamic) onReactF) {
    _socketService.on('react', onReactF);
  }

  void onMoveMade(dynamic Function(dynamic) onMoveMadeF) {
    _socketService.on('game-update', onMoveMadeF);
  }

  void makeMove(String move) {
    _socketService.emit('move', {"move": move});
  }

  void react(String reaction) {
    _socketService.emit('react', {"reaction": reaction});
  }
}

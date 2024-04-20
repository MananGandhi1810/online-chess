import 'package:online_chess/services/socket_service.dart';

class GameRepository {
  final SocketService _socketService = SocketService();
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
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  Socket? socket;

  bool get isConnected => socket?.connected ?? false;

  void connect(String baseUrl) {
    socket = io(baseUrl, <String, dynamic>{
      "transports": ["websocket"],
    });
    socket?.connect();
    socket?.onConnect((data) => debugPrint('Connected to server'));
  }

  void emit(String event, Map<String, dynamic> data) {
    debugPrint('Emitting $event with data: $data');
    String sendData = jsonEncode(data);
    socket?.emit(event, sendData);
  }

  void on(String event, dynamic Function(dynamic) callback) {
    socket?.on(event, callback);
  }
}

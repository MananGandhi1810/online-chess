import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_chess/repositories/auth_repository.dart';
import 'package:online_chess/services/storage_service.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService();

  bool get isAuthenticated => user != null;

  Future<void> getUserData() async {
    try {
      debugPrint("Getting user data");
      String? data = await _storageService.read("user");
      debugPrint(data);
      if (data == null) {
        return;
      }
      String token = jsonDecode(data)['token'];
      if (token.isEmpty) {
        return;
      }
      try {
        user = await _authRepository.getUserData(token);
        String newToken = await _authRepository.refreshToken(token);
        if (newToken.isNotEmpty) {
          user?.setToken(newToken);
          _storageService.write("user", jsonEncode(user?.toJson()));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Map> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    try {
      final res =
          await _authRepository.register(name, username, email, password);
      notifyListeners();
      return res;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    user = await _authRepository.login(email, password);
    if (user != null) {
      _storageService.write("user", jsonEncode(user?.toJson()));
    }
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    _storageService.delete("user");
    notifyListeners();
  }
}

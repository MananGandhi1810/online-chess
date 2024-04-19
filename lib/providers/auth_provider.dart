import 'package:flutter/material.dart';
import 'package:online_chess/repositories/auth_repository.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  AuthRepository _authRepository = AuthRepository();

  bool get isAuthenticated => user != null;

  void register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    user = await _authRepository.register(name, username, email, password);
    notifyListeners();
  }

  void login(String email, String password) async {
    user = await _authRepository.login(email, password);
    notifyListeners();
  }
}

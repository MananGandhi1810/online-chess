import 'package:flutter/material.dart';
import 'package:online_chess/services/network_service.dart';

import '../models/user_model.dart';

class AuthRepository {
  final NetworkService _networkService = NetworkService();
  String baseUrl = 'http://localhost:3000';

  Future<UserModel> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    try {
      Map<String, dynamic> response = await _networkService.post('$baseUrl/auth/register', {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to register');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      Map<String, dynamic> response = await _networkService.post('$baseUrl/auth/login', {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to login');
    }
  }
}

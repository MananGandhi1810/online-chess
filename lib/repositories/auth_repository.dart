import 'package:flutter/material.dart';
import 'package:online_chess/services/network_service.dart';

import '../constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final NetworkService _networkService = NetworkService();
  String baseUrl = Constants.httpBaseUrl;

  Future<Map<String, dynamic>> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    try {
      Map<String, dynamic> response =
          await _networkService.post('$baseUrl/register', {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });
      if (response['success'] == false) {
        throw Exception(response['message']);
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      Map<String, dynamic> response =
          await _networkService.post('$baseUrl/login', {
        'email': email,
        'password': password,
      });
      debugPrint(response.toString());
      if (response['success'] == false) {
        throw Exception(response['message']);
      }
      final user = UserModel.fromJson(response['data']['user']);
      user.setToken(response['data']['token']);
      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String token) async {
    try {
      Map<String, dynamic> response =
          await _networkService.get("$baseUrl/getUser", token: token);
      debugPrint(response.toString());
      final user = UserModel.fromJson(response['data']);
      return user;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to fetch user");
    }
  }

  Future<String> refreshToken(String token) async {
    try {
      Map<String, dynamic> response =
          await _networkService.get("$baseUrl/refreshToken", token: token);
      debugPrint(response.toString());
      return response['data']['token'];
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to refresh token");
    }
  }
}

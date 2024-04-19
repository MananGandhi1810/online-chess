import 'game_model.dart';

class UserModel {
  String name;
  String username;
  String email;
  List<GameModel> whiteGames;
  List<GameModel> blackGames;
  String? token;

  UserModel({
    required this.name,
    required this.username,
    required this.email,
    required this.whiteGames,
    required this.blackGames,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      username: json['username'],
      email: json['email'],
      whiteGames: json['whiteGames'],
      blackGames: json['blackGames'],
      token: json.keys.contains('token') ? json['token'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'whiteGames': whiteGames,
      'blackGames': blackGames,
      'token': token,
    };
  }
}

class UserModel {
  String id;
  String name;
  String username;
  String email;
  String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      token: json.keys.contains('token') ? json['token'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'token': token,
    };
  }

  void setToken(String token) {
    this.token = token;
  }
}

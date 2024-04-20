import 'user_model.dart';

class GameModel {
  String id;
  String whitePlayerUserId;
  String blackPlayerUserId;
  String status;
  List moves;
  String? result;
  String boardState;
  UserModel? winner;
  String? winnerId;

  GameModel({
    required this.id,
    required this.whitePlayerUserId,
    required this.blackPlayerUserId,
    required this.status,
    required this.moves,
    required this.result,
    required this.boardState,
    this.winner,
    this.winnerId,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['gameId'],
      whitePlayerUserId: json['whiteUser'],
      blackPlayerUserId: json['blackUser'],
      status: json['status'],
      moves: json['moves'],
      result: json['result'],
      boardState: json['boardState'],
      winner: json['winner'] != null ? UserModel.fromJson(json['winner']) : null,
      winnerId: json['winnerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'whitePlayerUserId': whitePlayerUserId,
      'blackPlayerUserId': blackPlayerUserId,
      'status': status,
      'moves': moves,
      'result': result,
      'boardState': boardState,
      'winner': winner?.toJson(),
      'winnerId': winnerId,
    };
  }
}

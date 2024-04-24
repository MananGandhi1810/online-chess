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
  UserModel? whitePlayer;
  UserModel? blackPlayer;

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
    this.whitePlayer,
    this.blackPlayer,
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
      winner:
          json['winner'] != null ? UserModel.fromJson(json['winner']) : null,
      winnerId: json['winnerId'],
      whitePlayer: json['whitePlayer'] != null
          ? UserModel.fromJson(json['whitePlayer'])
          : null,
      blackPlayer: json['blackPlayer'] != null
          ? UserModel.fromJson(json['blackPlayer'])
          : null,
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
      'whitePlayer': whitePlayer?.toJson(),
      'blackPlayer': blackPlayer?.toJson(),
    };
  }
}

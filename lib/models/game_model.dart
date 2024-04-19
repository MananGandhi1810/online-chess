class GameModel {
  String id;
  String whitePlayerUserId;
  String blackPlayerUserId;
  String status;
  List<String> moves;
  String? result;
  String boardState;

  GameModel({
    required this.id,
    required this.whitePlayerUserId,
    required this.blackPlayerUserId,
    required this.status,
    required this.moves,
    required this.result,
    required this.boardState,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      whitePlayerUserId: json['whitePlayerUserId'],
      blackPlayerUserId: json['blackPlayerUserId'],
      status: json['status'],
      moves: json['moves'],
      result: json['result'],
      boardState: json['boardState'],
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
    };
  }
}

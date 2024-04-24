import 'package:flutter/material.dart';

import '../models/game_model.dart';

class PastGamePage extends StatefulWidget {
  const PastGamePage({super.key, required this.game});

  final GameModel game;

  @override
  State<PastGamePage> createState() => _PastGamePageState();
}

class _PastGamePageState extends State<PastGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Placeholder(),
    );
  }
}

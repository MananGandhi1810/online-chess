import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';

class EmojiReactions extends StatelessWidget {
  const EmojiReactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            context.read<GameProvider>().react("😀");
          },
          icon: const Text(
            "😀",
            style: TextStyle(fontSize: 22),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<GameProvider>().react("😔");
          },
          icon: const Text(
            "😔",
            style: TextStyle(fontSize: 22),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<GameProvider>().react("😡");
          },
          icon: const Text(
            "😡",
            style: TextStyle(fontSize: 22),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<GameProvider>().react("😎");
          },
          icon: const Text(
            "😎",
            style: TextStyle(fontSize: 22),
          ),
        ),
      ],
    );
  }
}

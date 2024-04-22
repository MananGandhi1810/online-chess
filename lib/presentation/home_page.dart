import 'package:flutter/material.dart';
import 'package:online_chess/presentation/game_page.dart';
import 'package:online_chess/presentation/splash_page.dart';
import 'package:online_chess/providers/game_provider.dart';
import 'package:online_chess/providers/player_data_provider.dart';
import 'package:provider/provider.dart';

import '../models/game_model.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GameModel> userGames = [];

  void getUserGames() {
    context
        .read<PlayerDataProvider>()
        .getPlayerGames(context.read<AuthProvider>().user!.id, false)
        .then((value) {
      if (!mounted) return;
      setState(() {
        userGames = value;
      });
    });
  }

  @override
  void initState() {
    // getUserGames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Welcome, ${context.watch<AuthProvider>().user?.name.split(" ")[0] ?? ""}"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplashPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<GameProvider>().startGame();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamePage(),
                ),
              );
            },
            child: const Text("Start Game"),
          ),
        ],
      ),
    );
  }
}

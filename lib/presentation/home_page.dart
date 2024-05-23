import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_chess/presentation/game_page.dart';
import 'package:online_chess/presentation/splash_page.dart';
import 'package:online_chess/providers/game_provider.dart';
import 'package:online_chess/providers/player_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/game_model.dart';
import '../providers/auth_provider.dart';
import 'past_game_page.dart';

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
    Future.delayed(const Duration(milliseconds: 200), getUserGames);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Welcome, ${context.watch<AuthProvider>().user?.name.split(" ")[0] ?? ""}"),
        actions: [
          kIsWeb && MediaQuery.of(context).size.width < 600
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Download Android App"),
                          content: const Text(
                              "Do you want to download the android app for this game?"),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  launchUrl(
                                    Uri.parse(
                                      "https://go.manangandhi.tech/chess-android",
                                    ),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              child: const Text("Yes!"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.download),
                )
              : Container(),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SplashPage(),
                ),
              );
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: context.watch<AuthProvider>().user == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flex(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        direction: Axis.horizontal,
                        children: [
                          Card(
                            elevation: 10,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              onTap: () {
                                context.read<GameProvider>().startGame();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GamePage(),
                                  ),
                                ).then((value) => getUserGames());
                              },
                              child: SizedBox(
                                height: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(6),
                                          ),
                                          child: Image.asset(
                                            'assets/logo.jpg',
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Start Game",
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12),
                      ),
                      userGames != []
                          ? const Text(
                              "Your past games",
                              style: TextStyle(fontSize: 16),
                            )
                          : Container(),
                      for (GameModel game in userGames)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PastGamePage(
                                  game: game,
                                  opponent: game.blackPlayerUserId ==
                                          context.watch<AuthProvider>().user!.id
                                      ? game.whitePlayer
                                      : game.blackPlayer,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              "${context.watch<AuthProvider>().user!.name} vs. ${game.blackPlayerUserId == context.watch<AuthProvider>().user!.id ? game.whitePlayer?.name ?? "Loading..." : game.blackPlayer?.name ?? "Loading..."}",
                            ),
                            subtitle: Text(game.status),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

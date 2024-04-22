import 'package:flutter/material.dart';
import 'package:online_chess/providers/auth_provider.dart';
import 'package:online_chess/providers/game_provider.dart';
import 'package:provider/provider.dart';

import 'presentation/splash_page.dart';
import 'providers/player_data_provider.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerDataProvider(),
        ),
      ],
      child: MaterialApp(
        home: const SplashPage(),
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

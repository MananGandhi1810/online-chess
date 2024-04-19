import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [],
      child: const MaterialApp(
        home: Placeholder(),
      ),
    );
  }
}

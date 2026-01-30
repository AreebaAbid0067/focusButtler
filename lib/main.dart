import 'package:flutter/material.dart';
import 'package:productivity_app/screens/main_scaffold.dart';
import 'package:productivity_app/utils/theme.dart';

import 'package:provider/provider.dart';
import 'package:productivity_app/providers/focus_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FocusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyperfocus',
      theme: HyperfocusTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainScaffold(),
    );
  }
}

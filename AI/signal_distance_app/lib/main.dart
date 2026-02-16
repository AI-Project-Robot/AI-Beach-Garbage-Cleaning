import 'package:flutter/material.dart';

import 'api_settings_page.dart';

void main() {
  runApp(const SignalDistanceApp());
}

class SignalDistanceApp extends StatelessWidget {
  const SignalDistanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluvyn Beach Cleaning Robot',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const ApiHomePage(),
    );
  }
}

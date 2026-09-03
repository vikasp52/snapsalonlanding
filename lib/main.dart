import 'package:flutter/material.dart';

import 'coming_soon.dart';

void main() {
  runApp(const SnapSalonApp());
}

class SnapSalonApp extends StatelessWidget {
  const SnapSalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSalon — Coming Soon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
      ),
      home: const ComingSoonPage(),
    );
  }
}

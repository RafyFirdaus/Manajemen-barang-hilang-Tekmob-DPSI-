import 'package:flutter/material.dart';
import 'src/Welcome Screen/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Barang Hilang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F41BB)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

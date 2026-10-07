import 'package:flutter/material.dart';
import 'package:login_rive_animation_26_3_tsw/screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen()
    );
  }
}

import 'package:flutter/material.dart';
import '../home/screens/home_screen.dart';

/// Primary Navigation Entry Point for LearnX STREAM
class MainNavScreen extends StatelessWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}


import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/navigation/main_nav_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LearnXStreamApp());
}

class LearnXStreamApp extends StatelessWidget {
  final Widget? home;

  const LearnXStreamApp({
    super.key,
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'LearnX STREAM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: home ?? const MainNavScreen(),
        );
      },
    );
  }
}

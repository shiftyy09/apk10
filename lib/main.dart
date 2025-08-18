import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const GymFlowApp());

class GymFlowApp extends StatelessWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYMFLOW',
      theme: appTheme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

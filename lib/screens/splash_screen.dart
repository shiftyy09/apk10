import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'bmi_form.dart';
import 'workout_days_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _showLogo = false, _showForm = false, _checkingUserData = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showLogo = true);
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() => _showLogo = false);
    await Future.delayed(const Duration(milliseconds: 300));
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    if (!mounted) return;
    setState(() => _checkingUserData = true);
    final prefs = await SharedPreferences.getInstance();
    final hasBmi = prefs.getDouble('bmi') != null;
    final hasNickname = (prefs.getString('nickname') ?? '').isNotEmpty;
    if (!mounted) return;
    if (hasBmi && hasNickname) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorkoutDaysScreen()),
      );
    } else {
      setState(() {
        _checkingUserData = false;
        _showForm = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradientStart, gradientEnd]),
        ),
        child: Stack(
          children: [
            // moving orbs
            ...List.generate(6, (i) {
              return Positioned(
                top: 50 + i * 120,
                left: 20 + (i % 2) * 200,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    final dx = 20 * (i % 2 == 0 ? _animationController.value : -_animationController.value);
                    final dy = 15 * _animationController.value;
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        width: 80 + i * 10,
                        height: 80 + i * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05)
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            if (!_checkingUserData && !_showForm)
              Center(
                child: AnimatedOpacity(
                  opacity: _showLogo ? 1 : 0,
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      _LogoBadge(),
                      SizedBox(height: 30),
                      _TitleBlock(),
                    ]),
                  ),
                ),
              ),
            if (_checkingUserData)
              const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))),
            if (_showForm)
              const Center(child: BmiForm()),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          "assets/gymflo_logo.png", // vagy a pontos útvonal, ha .jpg, stb.
          fit: BoxFit.contain,
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}


class _TitleBlock extends StatelessWidget {
  const _TitleBlock();
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: const [
        Text('GYMFLOW', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 3)),
        SizedBox(height: 10),
    Text(
        'GYMFLOW – Mozdulj a flow-val!.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.white70)),
      ]);

}
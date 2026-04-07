import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/screen/auth/login_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final uid = await UserPrefs.getUid();
    
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => (uid != null) ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/diu_logo.png', height: 90),
            const SizedBox(height: 24),
            const Text(
              'Campus Blood Donorly',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save a Life. Donate Blood.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

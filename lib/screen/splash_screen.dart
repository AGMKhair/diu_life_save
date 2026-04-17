import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/screen/auth/login_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndAuth();
  }

  Future<void> _checkVersionAndAuth() async {
    try {
      // ১. বর্তমান অ্যাপের বিল্ড নাম্বার (versionCode) নেওয়া
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String buildNumberStr = packageInfo.buildNumber;
      final int currentBuildNumber = int.tryParse(buildNumberStr) ?? 3;
      
      debugPrint("Current Build Number: $currentBuildNumber");

      // ২. ফায়ারবেস থেকে মিনিমাম রিকোয়ার্ড ভার্সন কোড আনা
      final DocumentSnapshot settings = await FirebaseFirestore.instance
          .collection('settings')
          .doc('app_config')
          .get();

      if (settings.exists) {
        final Map<String, dynamic> data = settings.data() as Map<String, dynamic>;
        final int minRequiredVersion = data['min_version'] ?? 3;
        debugPrint("Minimum Required Version: $minRequiredVersion");

        // ৩. চেক করা: যদি বর্তমান ভার্সন ফায়ারবেসের ভার্সন থেকে ছোট হয়
        if (currentBuildNumber < minRequiredVersion) {
          _showUpdateDialog();
          return; // আপডেট ডায়ালগ দেখালে আর সামনে আগাবে না
        }
      }
      
      _proceedToNextScreen();
    } catch (e) {
      debugPrint("Error checking version: $e");
      _proceedToNextScreen(); // এরর হলে অ্যাপে ঢুকতে দিবে
    }
  }

  void _proceedToNextScreen() async {
    final uid = await UserPrefs.getUid();
    if (!mounted) return;

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

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text("Update Available"), // টাইটেল একটু পরিবর্তন করা হলো
          content: const Text("আপনার অ্যাপে নতুন কিছু আপডেট এসেছে। নিরবচ্ছিন্ন সেবা পেতে দয়া করে প্লে-স্টোর থেকে লেটেস্ট ভার্সনটি আপডেট করে নিন।"),
          actions: [
            TextButton(
              onPressed: () => _launchUpdateUrl(),
              child: const Text(
                "Update Now",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _launchUpdateUrl() async {
    const url = 'https://play.google.com/store/apps/details?id=com.spontit.agmkhair.diu_life_save';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primaryRed),
          ],
        ),
      ),
    );
  }
}

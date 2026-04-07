import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      // 1. Get user document from Firestore using the phone number
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .get();

      if (!userDoc.exists) {
        AppSnackBar.showError(context, message: 'User not found');
        return;
      }

      // 2. Verify password
      final userData = userDoc.data();
      if (userData != null && userData['password'] == password) {
        // Success - Save UID (phone) locally
        await UserPrefs.setUid(phone);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        AppSnackBar.showError(context, message: 'Incorrect password');
      }

    } catch (e) {
      AppSnackBar.showError(context, message: 'Login Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Image.asset(
                'assets/images/diu_logo.png',
                height: 90,
              ),

              const SizedBox(height: 20),

              const Text(
                'Campus Blood Donorly',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                'Save a Life. Donate Blood.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

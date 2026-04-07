import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final phoneController = TextEditingController();
  final batchController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {
    final phone = phoneController.text.trim();
    final batch = batchController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (phone.isEmpty || batch.isEmpty || newPassword.isEmpty) {
      AppSnackBar.showError(context, message: 'Please fill all fields');
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

      final userData = userDoc.data();
      
      // 2. Verify with another data (using Batch as requested)
      if (userData != null && userData['batch'] == batch) {
        // 3. Update Password
        await FirebaseFirestore.instance
            .collection('users')
            .doc(phone)
            .update({'password': newPassword});

        // 4. Success - Save UID (phone) locally and login
        await UserPrefs.setUid(phone);
        
        if (!mounted) return;
        AppSnackBar.showSuccess(context, message: 'Password reset successful');
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        AppSnackBar.showError(context, message: 'Batch information did not match');
      }

    } catch (e) {
      AppSnackBar.showError(context, message: 'Reset Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Reset your password by verifying your account details.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: batchController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Your Batch (e.g. 58)',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : resetPassword,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Reset & Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

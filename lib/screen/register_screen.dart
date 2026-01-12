import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedBloodGroup = 'O+';

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              /// 🩸 APP TITLE
              const Text(
                'Join DIU LifeSave',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Be a part of the blood donor community',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              /// 📝 REGISTER CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// NAME
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// DEPARTMENT
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🩸 BLOOD GROUP
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Blood Group',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children: bloodGroups.map((bg) {
                          return ChoiceChip(
                            showCheckmark: false,
                            avatar: Icon(
                              Icons.bloodtype,
                              size: 18,
                              color: selectedBloodGroup == bg
                                  ? Colors.white
                                  : AppColors.primaryRed,
                            ),
                            label: Text(
                              bg,
                              style: TextStyle(
                                color: selectedBloodGroup == bg
                                    ? Colors.white
                                    : AppColors.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selectedBloodGroup == bg,
                            selectedColor: AppColors.primaryRed,
                            backgroundColor: Colors.grey.shade200,
                            onSelected: (_) {
                              setState(() {
                                selectedBloodGroup = bg;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      /// REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔙 BACK TO LOGIN
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

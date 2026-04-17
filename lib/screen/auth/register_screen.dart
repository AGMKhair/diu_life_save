import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String selectedBloodGroup = 'O+';
  String selectedArea = 'Dhaka';
  DateTime? lastDonationDate;
  bool isLoading = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final departmentController = TextEditingController();
  final batchController = TextEditingController();

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  final List<String> areas = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Sylhet',
    'Barishal',
    'Rangpur',
    'Mymensingh',
  ];

  Future<void> pickLastDonationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => lastDonationDate = picked);
    }
  }

  Future<void> registerDonor() async {
    final phone = phoneController.text.trim();

    if (nameController.text.isEmpty ||
        phone.isEmpty ||
        passwordController.text.isEmpty ||
        departmentController.text.isEmpty ||
        batchController.text.isEmpty) {
      AppSnackBar.showError(context, message: 'Please fill all required fields');
      return;
    }

    if (phone.length != 11) {
      AppSnackBar.showError(context, message: 'Phone number must be 11 digits');
      return;
    }

    try {
      setState(() => isLoading = true);

      // 1. Check if user already exists
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(phone).get();
      if (userDoc.exists) {
        AppSnackBar.showError(context, message: 'Phone number already registered');
        return;
      }

      // 2. Prepare Donor Model
      final donor = DonorModel(
        id: phone, // Use phone as ID
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        phone: phone,
        department: departmentController.text.trim(),
        batch: batchController.text.trim(),
        area: selectedArea,
        bloodGroup: selectedBloodGroup,
        lastDonationDate: lastDonationDate,
        age: 0,
        weight: 0,
        isAvailable: true,
      );

      // 3. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .set(donor.toMap());

      // 4. Save UID locally
      await UserPrefs.setUid(phone);

      // 5. Navigate to Home
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      AppSnackBar.showError(context, message: 'Registration failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Join Campus Blood Donorly',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _Field(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      controller: nameController,
                    ),

                    const SizedBox(height: 16),

                    _Field(
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      type: TextInputType.phone,
                      controller: phoneController,
                      maxLength: 11,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isNotEmpty && newValue.text[0] != '0') {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _Field(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 16),

                    _Field(
                      label: 'Department',
                      icon: Icons.school_outlined,
                      controller: departmentController,
                    ),

                    const SizedBox(height: 16),

                    _Field(
                      label: 'Batch',
                      icon: Icons.groups_outlined,
                      controller: batchController,
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedArea,
                      items: areas
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedArea = v!),
                      decoration: const InputDecoration(
                        labelText: 'Area / Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 8,
                      children: bloodGroups.map((bg) {
                        return ChoiceChip(
                          selected: selectedBloodGroup == bg,
                          label: Text(bg),
                          selectedColor: AppColors.primaryRed,
                          labelStyle: TextStyle(
                            color: selectedBloodGroup == bg
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) =>
                              setState(() => selectedBloodGroup = bg),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: pickLastDonationDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 10),
                            Text(
                              lastDonationDate == null
                                  ? 'Last Blood Donation Date'
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(lastDonationDate!),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : registerDonor,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Register'),
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

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextInputType type;
  final TextEditingController controller;
  final bool isPassword;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.type = TextInputType.text,
    this.isPassword = false,
    this.formatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      maxLength: maxLength,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon),
        counterText: maxLength != null ? "" : null,
      ),
    );
  }
}

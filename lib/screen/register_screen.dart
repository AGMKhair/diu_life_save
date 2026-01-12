import 'package:diu_life_save/screen/home_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';
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


  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
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
      setState(() {
        lastDonationDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Join Campus Blood Donorly',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Be a part of the blood donor community',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// FULL NAME
                      const _Field(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      /// MOBILE
                      const _Field(
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        type: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      /// DEPARTMENT
                      const _Field(
                        label: 'Department',
                        icon: Icons.school_outlined,
                      ),

                      const SizedBox(height: 16),

                      /// AREA
                      DropdownButtonFormField<String>(
                        value: selectedArea,
                        items: areas
                            .map((a) =>
                            DropdownMenuItem(value: a, child: Text(a)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedArea = v!),
                        decoration: const InputDecoration(
                          labelText: 'Area / Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BLOOD GROUP
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
                        runSpacing: 10,
                        children: bloodGroups.map((bg) {
                          return ChoiceChip(
                            showCheckmark: false,
                            selected: selectedBloodGroup == bg,
                            selectedColor: AppColors.primaryRed,
                            backgroundColor: Colors.grey.shade200,
                            label: Text(
                              bg,
                              style: TextStyle(
                                color: selectedBloodGroup == bg
                                    ? Colors.white
                                    : AppColors.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onSelected: (_) =>
                                setState(() => selectedBloodGroup = bg),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      /// 🩸 LAST DONATION DATE
                      InkWell(
                        onTap: pickLastDonationDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined),
                              const SizedBox(width: 10),
                              Text(
                                lastDonationDate == null
                                    ? 'Last Blood Donation Date'
                                    : DateFormat('dd MMM yyyy').format(lastDonationDate!),
                                style: TextStyle(
                                  color: lastDonationDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      const SizedBox(height: 30),

                      /// REGISTER
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

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextInputType type;

  const _Field({
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

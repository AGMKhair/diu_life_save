import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedBloodGroup = 'O+';
  DateTime? requiredDate;

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        requiredDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔴 MAIN CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🩸 BLOOD GROUP
                    const Text(
                      'Select Blood Group',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

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

                    const SizedBox(height: 24),

                    /// 📍 LOCATION
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 📞 PHONE
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 📅 REQUIRED DATE
                    InkWell(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 12),
                            Text(
                              requiredDate == null
                                  ? 'Required Date'
                                  : DateFormat('dd MMM yyyy')
                                  .format(requiredDate!),
                              style: TextStyle(
                                color: requiredDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔥 POST BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bloodtype),
                label: const Text('Post Blood Request'),
                onPressed: () {
                  // TODO: Firebase post logic
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

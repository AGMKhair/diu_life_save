import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? profileImage;

  final TextEditingController nameController =
  TextEditingController(text: 'AJM Tanvir');
  final TextEditingController phoneController = TextEditingController();

  String selectedBloodGroup = 'O+';
  String selectedLocation = 'Dhaka';
  bool isAvailable = true;

  DateTime? lastDonateDate;

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> bdLocations = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Sylhet',
    'Barishal',
    'Rangpur',
    'Mymensingh',
  ];

  Future<void> pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<void> pickLastDonateDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        lastDonateDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 👤 PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📝 PROFILE CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NAME
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// PHONE
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// BLOOD GROUP
                    const Text(
                      'Blood Group',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,
                      children: bloodGroups.map((bg) {
                        return ChoiceChip(
                          label: Text(bg),
                          selected: selectedBloodGroup == bg,
                          onSelected: (_) {
                            setState(() {
                              selectedBloodGroup = bg;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    /// LOCATION
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      items: bdLocations
                          .map(
                            (loc) => DropdownMenuItem(
                          value: loc,
                          child: Text(loc),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedLocation = v!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LAST DONATION DATE
                    InkWell(
                      onTap: pickLastDonateDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 10),
                            Text(
                              lastDonateDate == null
                                  ? 'Last Donation Date'
                                  : DateFormat('dd MMM yyyy')
                                  .format(lastDonateDate!),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// AVAILABILITY
                    SwitchListTile(
                      value: isAvailable,
                      onChanged: (v) {
                        setState(() {
                          isAvailable = v;
                        });
                      },
                      title: const Text('Available for Donation'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
                onPressed: () {
                  // TODO: Firebase Firestore + Storage save
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

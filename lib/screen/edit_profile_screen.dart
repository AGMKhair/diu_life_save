import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();

  String selectedBloodGroup = 'O+';
  String selectedLocation = 'Dhaka';
  bool isAvailable = true;
  DateTime? lastDonateDate;

  final bloodGroups = ['A+','A-','B+','B-','O+','O-','AB+','AB-'];
  final locations = [
    'Dhaka','Chattogram','Rajshahi','Khulna',
    'Sylhet','Barishal','Rangpur','Mymensingh'
  ];

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
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
      setState(() => lastDonateDate = picked);
    }
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final model = DonorModel(
      id: uid,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      department: '', // can be empty
      age: int.tryParse(ageController.text.trim()) ?? 0,
      weight: int.tryParse(weightController.text.trim()) ?? 0,
      bloodGroup: selectedBloodGroup,
      area: selectedLocation,
      isAvailable: isAvailable,
      lastDonationDate: lastDonateDate,
      profileImage: null, // for now
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(model.toMap(), SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Updated Successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// IMAGE
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 52,
                backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
                child:
                profileImage == null ? const Icon(Icons.person, size: 48) : null,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [

                    _field(nameController, 'Full Name', Icons.person),
                    _field(phoneController, 'Mobile Number', Icons.phone,
                        type: TextInputType.phone),
                    _field(ageController, 'Age', Icons.cake,
                        type: TextInputType.number),
                    _field(weightController, 'Weight (kg)',
                        Icons.monitor_weight,
                        type: TextInputType.number),

                    const SizedBox(height: 16),

                    /// BLOOD GROUP
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: bloodGroups.map((bg) {
                        return ChoiceChip(
                          showCheckmark: false,
                          selected: selectedBloodGroup == bg,
                          selectedColor: AppColors.primaryRed,
                          label: Text(
                            bg,
                            style: TextStyle(
                              color: selectedBloodGroup == bg
                                  ? Colors.white
                                  : AppColors.primaryRed,
                            ),
                          ),
                          onSelected: (_) =>
                              setState(() => selectedBloodGroup = bg),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: selectedLocation,
                      items: locations
                          .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedLocation = v!),
                      decoration: const InputDecoration(
                        labelText: 'Address / Area',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: pickLastDonateDate,
                      child: _dateBox(
                        lastDonateDate == null
                            ? 'Last Donation Date'
                            : DateFormat('dd MMM yyyy')
                            .format(lastDonateDate!),
                      ),
                    ),

                    SwitchListTile(
                      value: isAvailable,
                      onChanged: (v) =>
                          setState(() => isAvailable = v),
                      title: const Text('Available for Donation'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
                onPressed: saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration:
        InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _dateBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}

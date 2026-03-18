import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/screen/post/post_details_screen.dart';
import 'package:diu_life_save/screen/splash_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  File? _imageFile;
  
  // Controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  
  String? selectedBloodGroup;
  String? selectedLocation;
  DateTime? lastDonateDate;

  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final locations = [
    'Dhaka', 'Chattogram', 'Rajshahi', 'Khulna', 
    'Sylhet', 'Barishal', 'Rangpur', 'Mymensingh',
  ];

  void _initializeControllers(DonorModel data) {
    nameController.text = data.name;
    departmentController.text = data.department;
    batchController.text = data.batch;
    phoneController.text = data.phone;
    ageController.text = data.age.toString();
    weightController.text = data.weight.toString();
    selectedBloodGroup = data.bloodGroup;
    selectedLocation = data.area;
    lastDonateDate = data.lastDonationDate;
  }

  Future<void> _updateAvailability(bool value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isAvailable': value});
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    // In a real app, upload _imageFile to Firebase Storage first and get URL
    // For now, keeping the old URL if no new image is selected
    
    Map<String, dynamic> updateData = {
      'name': nameController.text.trim(),
      'department': departmentController.text.trim(),
      'batch': batchController.text.trim(),
      'phone': phoneController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'weight': int.tryParse(weightController.text.trim()) ?? 0,
      'bloodGroup': selectedBloodGroup,
      'area': selectedLocation,
      'lastDonationDate': lastDonateDate != null ? Timestamp.fromDate(lastDonateDate!) : null,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updateData);

    setState(() {
      isEditing = false;
      _imageFile = null;
    });
    
    if (mounted) {
      AppSnackBar.showSuccess(context, message: 'Profile Updated Successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'My Profile'),
        centerTitle: true,
        actions: [
          if (!isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.diuGreen),
              onPressed: () => setState(() => isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primaryRed),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => isEditing = false),
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Profile data not found"));
          }

          final data = DonorModel.fromMap(
            uid,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          if (!isEditing) {
            _initializeControllers(data);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (data.profileImage != null && data.profileImage!.isNotEmpty
                                        ? NetworkImage(data.profileImage!) as ImageProvider
                                        : null),
                                child: _imageFile == null && (data.profileImage == null || data.profileImage!.isEmpty)
                                    ? const Icon(Icons.person, size: 48)
                                    : null,
                              ),
                              if (isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryRed,
                                      child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isEditing)
                            _editField(nameController, 'Name', Icons.person)
                          else
                            Text(
                              data.name.isNotEmpty ? data.name : "—",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          const SizedBox(height: 6),
                          if (isEditing)
                            _bloodGroupSelector()
                          else
                            _badge(data.bloodGroup.isNotEmpty ? data.bloodGroup : "—"),
                          const SizedBox(height: 10),
                          
                          // Availability Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _availabilityBadge(data.isAvailable),
                              const SizedBox(width: 8),
                              Switch(
                                value: data.isAvailable,
                                activeColor: Colors.green,
                                onChanged: (val) => _updateAvailability(val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                
                // Details Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (isEditing) ...[
                          _editField(phoneController, 'Mobile', Icons.phone, type: TextInputType.phone),
                          _editField(departmentController, 'Department', Icons.school),
                          _editField(batchController, 'Batch', Icons.groups_outlined),
                          _editLocationDropdown(),
                          _editDatePicker(context),
                          Row(
                            children: [
                              Expanded(child: _editField(ageController, 'Age', Icons.cake, type: TextInputType.number)),
                              const SizedBox(width: 10),
                              Expanded(child: _editField(weightController, 'Weight', Icons.monitor_weight, type: TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ] else ...[
                          _infoTile(Icons.phone, 'Mobile', data.phone),
                          const Divider(),
                          _infoTile(Icons.school, 'Department', data.department),
                          const Divider(),
                          _infoTile(Icons.groups_outlined, 'Batch', data.batch),
                          const Divider(),
                          _infoTile(
                            Icons.calendar_month,
                            'Last Donation',
                            data.lastDonationDate != null
                                ? DateFormat('dd MMM yyyy').format(data.lastDonationDate!)
                                : 'Not donated yet',
                          ),
                          const Divider(),
                          _infoTile(Icons.location_on, 'Area', data.area),
                          const Divider(),
                          _infoTile(Icons.cake, 'Age', '${data.age} years'),
                          const Divider(),
                          _infoTile(Icons.monitor_weight, 'Weight', '${data.weight} kg'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _editField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _editLocationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: locations.contains(selectedLocation) ? selectedLocation : null,
        items: locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: (v) => setState(() => selectedLocation = v),
        decoration: InputDecoration(
          labelText: 'Area',
          prefixIcon: const Icon(Icons.location_on, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _editDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: lastDonateDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => lastDonateDate = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Text(
                lastDonateDate != null ? DateFormat('dd MMM yyyy').format(lastDonateDate!) : 'Last Donation Date',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bloodGroupSelector() {
    return Wrap(
      spacing: 6,
      children: bloodGroups.map((bg) {
        final isSelected = selectedBloodGroup == bg;
        return ChoiceChip(
          label: Text(bg, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
          selected: isSelected,
          selectedColor: AppColors.primaryRed,
          onSelected: (val) => setState(() => selectedBloodGroup = bg),
        );
      }).toList(),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _availabilityBadge(bool available) {
    final color = available ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Available for Donation' : 'Not Available',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "—",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

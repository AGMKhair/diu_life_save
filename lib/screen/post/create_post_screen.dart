import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/blood_request_model.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController patientNameCtrl = TextEditingController();
  final TextEditingController problemCtrl = TextEditingController();
  final TextEditingController unitCtrl = TextEditingController();
  final TextEditingController hospitalCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  String selectedBloodGroup = 'O+';
  DateTime? requiredDate;
  TimeOfDay? requiredTime;
  bool isEmergency = false;

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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => requiredDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => requiredTime = picked);
    }
  }

  Future<void> submitPost() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final requiredDateTime = DateTime(
        requiredDate!.year,
        requiredDate!.month,
        requiredDate!.day,
        requiredTime!.hour,
        requiredTime!.minute,
      );

      final expireAt = requiredDateTime.add(const Duration(hours: 24));

      final model = BloodRequestModel(
        id: "",
        uid: user.uid,
        patientName: patientNameCtrl.text.trim(),
        problem: problemCtrl.text.trim(),
        bloodGroup: selectedBloodGroup,
        units: int.parse(unitCtrl.text.trim()),
        hospital: hospitalCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        note: noteCtrl.text.trim(),
        isEmergency: isEmergency,
        requiredDateTime: requiredDateTime,
        createdAt: DateTime.now(),
        expireAt: expireAt,
      );

      await FirebaseFirestore.instance.collection('posts').add(model.toMap());

      AppSnackBar.showSuccess(context, message: "Your blood request completed");
      Navigator.pop(context);
    } catch (e) {
      AppSnackBar.showError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Blood Request',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🧑 PATIENT NAME
                TextField(
                  controller: patientNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 14),

                /// 🩺 PROBLEM
                TextField(
                  controller: problemCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Patient Problem',
                    prefixIcon: Icon(Icons.medical_information_outlined),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🩸 BLOOD GROUP
                const Text(
                  'Blood Group',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
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
                      onSelected: (_) {
                        setState(() => selectedBloodGroup = bg);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                /// 🧪 REQUIRED UNITS
                TextField(
                  controller: unitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Required Units (Bag)',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                ),

                const SizedBox(height: 14),

                /// 🏥 HOSPITAL
                TextField(
                  controller: hospitalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name',
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                ),

                const SizedBox(height: 14),

                /// 📍 LOCATION
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Address / Location',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),

                const SizedBox(height: 14),

                /// 📞 CONTACT
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),

                const SizedBox(height: 20),

                /// 📅 DATE & TIME

                Container(
                  child: InkWell(
                    onTap: pickDate,
                    child: _dateTimeBox(
                      icon: Icons.calendar_month_outlined,
                      text: requiredDate == null
                          ? 'Required Date'
                          : DateFormat('dd MMM yyyy').format(requiredDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  child: InkWell(
                    onTap: pickTime,
                    child: _dateTimeBox(
                      icon: Icons.access_time,
                      text: requiredTime == null
                          ? 'Required Time'
                          : requiredTime!.format(context),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// 🚨 EMERGENCY
                SwitchListTile(
                  value: isEmergency,
                  onChanged: (v) => setState(() => isEmergency = v),
                  title: const Text('Emergency'),
                  activeColor: AppColors.primaryRed,
                ),

                const SizedBox(height: 14),

                /// 📝 NOTES
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 SUBMIT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Blood Request'),
                    onPressed: () {
                      submitPost();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTimeBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [Icon(icon), const SizedBox(width: 10), Text(text)]),
    );
  }
}

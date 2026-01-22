import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/blood_request_model.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final BloodRequestModel model;

  const EditPostScreen({super.key, required this.model});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController patientCtrl;
  late TextEditingController problemCtrl;
  late TextEditingController unitsCtrl;
  late TextEditingController hospitalCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController noteCtrl;

  String selectedBloodGroup = 'O+';
  bool isEmergency = false;
  DateTime requiredDateTime = DateTime.now();
  DateTime expireAt = DateTime.now().add(const Duration(days: 2));

  final bloodGroups = ['A+','A-','B+','B-','O+','O-','AB+','AB-'];

  @override
  void initState() {
    super.initState();

    patientCtrl = TextEditingController(text: widget.model.patientName);
    problemCtrl = TextEditingController(text: widget.model.problem);
    unitsCtrl = TextEditingController(text: widget.model.units.toString());
    hospitalCtrl = TextEditingController(text: widget.model.hospital);
    locationCtrl = TextEditingController(text: widget.model.location);
    phoneCtrl = TextEditingController(text: widget.model.phone);
    noteCtrl = TextEditingController(text: widget.model.note);

    selectedBloodGroup = widget.model.bloodGroup;
    isEmergency = widget.model.isEmergency;
    requiredDateTime = widget.model.requiredDateTime;
    expireAt = widget.model.expireAt;
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: requiredDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(requiredDateTime),
    );

    if (time == null) return;

    setState(() {
      requiredDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> updatePost() async {
    final updatedModel = BloodRequestModel(
      id: widget.model.id,
      uid: widget.model.uid,
      patientName: patientCtrl.text.trim(),
      problem: problemCtrl.text.trim(),
      bloodGroup: selectedBloodGroup,
      units: int.parse(unitsCtrl.text.trim()),
      hospital: hospitalCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      note: noteCtrl.text.trim(),
      isEmergency: isEmergency,
      requiredDateTime: requiredDateTime,
      createdAt: widget.model.createdAt,
      expireAt: expireAt,
    );

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.model.id)
        .update(updatedModel.toMap());

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Post',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _field(patientCtrl, 'Patient Name'),
            _field(problemCtrl, 'Problem'),
            _field(unitsCtrl, 'Units', type: TextInputType.number),
            const SizedBox(height: 12),

            /// Blood Group
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bloodGroups.map((bg) {
                return ChoiceChip(
                  label: Text(bg),
                  selected: selectedBloodGroup == bg,
                  selectedColor: AppColors.primaryRed,
                  onSelected: (_) => setState(() => selectedBloodGroup = bg),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            _field(hospitalCtrl, 'Hospital'),
            _field(locationCtrl, 'Location'),
            _field(phoneCtrl, 'Phone', type: TextInputType.phone),
            _field(noteCtrl, 'Note'),

            const SizedBox(height: 12),

            /// Required Date & Time
            InkWell(
              onTap: pickDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 10),
                    Text(
                      'Required: ${requiredDateTime.toString().split('.').first}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              value: isEmergency,
              onChanged: (v) => setState(() => isEmergency = v),
              title: const Text('Emergency'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Update Post'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

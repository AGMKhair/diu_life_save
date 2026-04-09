import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/blood_request_model.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/util/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String myBloodGroup = '';

  @override
  void initState() {
    super.initState();
    _loadMyBloodGroup();
  }

  /// 🔹 Logged in user blood group
  Future<void> _loadMyBloodGroup() async {
    final uid = await UserPrefs.getUid();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final donor = DonorModel.fromMap(doc.id, doc.data()!);
      setState(() {
        myBloodGroup = donor.bloodGroup;
      });
    }
  }

  /// 🔥 Active notifications stream
  Stream<QuerySnapshot> _notificationStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('bloodGroup', isEqualTo: myBloodGroup)
        .where('requiredDateTime', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: myBloodGroup.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _notificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active requests for your blood group'),
            );
          }

          final requests = snapshot.data!.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (_, index) {
              return _requestCard(requests[index]);
            },
          );
        },
      ),
    );
  }

  /// 🩸 REQUEST CARD
  Widget _requestCard(BloodRequestModel data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔴 TOP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _bloodBadge(data.bloodGroup),
                    const SizedBox(width: 10),
                    const Text(
                      'Blood Needed',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                _statusBadge(data.isEmergency),
              ],
            ),

            const SizedBox(height: 12),

            /// 🧑 PATIENT NAME
            _infoRow(Icons.person_outline, 'Patient', data.patientName),

            /// 🩺 PROBLEM
            _infoRow(Icons.medical_information_outlined, 'Problem', data.problem),

            /// 🧪 UNITS
            _infoRow(
              Icons.bloodtype_outlined,
              'Required Units',
              '${data.units} Bags',
            ),

            /// 🏥 HOSPITAL
            _infoRow(Icons.local_hospital_outlined, 'Hospital', data.hospital),

            /// 📍 LOCATION
            _infoRow(Icons.location_on_outlined, 'Location', data.location),

            /// 📅 DATE & TIME
            _infoRow(
              Icons.calendar_month_outlined,
              'Date & Time',
              DateFormat('dd MMM yyyy • hh:mm a')
                  .format(data.requiredDateTime),
            ),

            /// 📝 NOTES (Optional)
            _infoRow(Icons.note_outlined, 'Notes', data.note.isNotEmpty ? data.note : '—'),

            const SizedBox(height: 16),

            /// 📞 CALL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Requester'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _callNumber(data.phone),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🩸 Blood badge
  Widget _bloodBadge(String group) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        group,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🚨 Status badge
  Widget _statusBadge(bool emergency) {
    final color = emergency ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        emergency ? 'Emergency' : 'Pending',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style:
                    const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

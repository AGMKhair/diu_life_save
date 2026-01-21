import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  List<String> myBloodGroups = [];

  @override
  void initState() {
    super.initState();
    getMyBloodGroup();
  }

  Future<void> getMyBloodGroup() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        myBloodGroups = List<String>.from(doc.data()!['bloodGroup'] ?? []);
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationStream() {
    // This will show notifications for any of the user's blood groups
    return FirebaseFirestore.instance
        .collection('posts')
        .where('bloodGroup', whereIn: myBloodGroups)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryRed,
        centerTitle: true,
      ),
      body: myBloodGroups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No notifications for your blood group"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final data = docs[index].data();
              return _requestCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> data) {
    final bool isEmergency = data['isEmergency'] ?? false;

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
            /// 🔴 TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['bloodGroup'] ?? 'O+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Blood Needed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                /// STATUS / EMERGENCY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEmergency
                        ? Colors.red.withOpacity(.15)
                        : Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEmergency ? 'Emergency' : 'Pending',
                    style: TextStyle(
                      color: isEmergency ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _infoRow(Icons.person_outline, 'Patient', data['patientName'] ?? 'Unknown'),
            _infoRow(Icons.medical_information_outlined, 'Problem', data['problem'] ?? 'Unknown'),
            _infoRow(Icons.bloodtype_outlined, 'Required Units', data['units'] ?? '0'),
            _infoRow(Icons.local_hospital_outlined, 'Hospital', data['hospital'] ?? 'Unknown'),
            _infoRow(Icons.location_on_outlined, 'Location', data['location'] ?? 'Unknown'),
            _infoRow(Icons.calendar_month_outlined, 'Date & Time', data['dateTime'] ?? 'Unknown'),
            _infoRow(Icons.note_outlined, 'Notes', data['notes'] ?? 'None'),

            const SizedBox(height: 16),

            /// 📞 CALL BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Requester'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  makePhoneCall(data['phone'] ?? '017XXXXXXXX');
                },
              ),
            ),
          ],
        ),
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
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

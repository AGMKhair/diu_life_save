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

  /// 🔥 Notification stream (Only filtering by blood group to avoid index issues)
  Stream<QuerySnapshot> _notificationStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('bloodGroup', isEqualTo: myBloodGroup)
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
              child: Text('No requests found for your blood group'),
            );
          }

          final allRequests = snapshot.data!.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .toList();

          final now = DateTime.now();
          
          // All future requests
          final runningRequests = allRequests
              .where((r) => r.requiredDateTime.isAfter(now))
              .toList();
              
          // Only today's expired requests
          final expiredRequests = allRequests
              .where((r) {
                final isExpired = r.requiredDateTime.isBefore(now);
                final isToday = r.requiredDateTime.year == now.year &&
                                r.requiredDateTime.month == now.month &&
                                r.requiredDateTime.day == now.day;
                return isExpired && isToday;
              })
              .toList();

          // Sort: Running requests (nearest first), Expired (latest first)
          runningRequests.sort((a, b) => a.requiredDateTime.compareTo(b.requiredDateTime));
          expiredRequests.sort((a, b) => b.requiredDateTime.compareTo(a.requiredDateTime));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (runningRequests.isNotEmpty) ...[
                _sectionHeader('Running Requests', Colors.green),
                ...runningRequests.map((req) => _requestCard(req, false)),
              ],
              if (expiredRequests.isNotEmpty) ...[
                const SizedBox(height: 20),
                _sectionHeader('Time Over / Inactive (Today)', Colors.grey),
                ...expiredRequests.map((req) => _requestCard(req, true)),
              ],
              if (runningRequests.isEmpty && expiredRequests.isEmpty)
                const Center(child: Text('No active requests found')),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  /// 🩸 REQUEST CARD
  Widget _requestCard(BloodRequestModel data, bool isExpired) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isExpired ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isExpired ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
      ),
      child: Opacity(
        opacity: isExpired ? 0.7 : 1.0,
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
                      _bloodBadge(data.bloodGroup, isExpired),
                      const SizedBox(width: 10),
                      const Text(
                        'Blood Needed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  _statusBadge(data.isEmergency, isExpired),
                ],
              ),

              const SizedBox(height: 12),

              _infoRow(Icons.person_outline, 'Patient', data.patientName),
              _infoRow(Icons.medical_information_outlined, 'Problem', data.problem),
              _infoRow(Icons.bloodtype_outlined, 'Required Units', '${data.units} Bags'),
              _infoRow(Icons.local_hospital_outlined, 'Hospital', data.hospital),
              _infoRow(Icons.location_on_outlined, 'Location', data.location),

              /// 📅 DATE & TIME
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            const TextSpan(
                              text: 'Date & Time: ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: DateFormat('dd MMM yyyy • hh:mm a').format(data.requiredDateTime),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Time Over',
                          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              _infoRow(Icons.note_outlined, 'Notes', data.note.isNotEmpty ? data.note : '—'),

              const SizedBox(height: 16),

              /// 📞 CALL
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Call Requester'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired ? Colors.grey : AppColors.primaryRed,
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
      ),
    );
  }

  /// 🩸 Blood badge
  Widget _bloodBadge(String group, bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExpired ? Colors.grey : AppColors.primaryRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        group,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🚨 Status badge
  Widget _statusBadge(bool emergency, bool isExpired) {
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Inactive',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      );
    }
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

  void _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

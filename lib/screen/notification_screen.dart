import 'package:flutter/material.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text('Notifications',
          style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: AppColors.primaryRed,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // later: replace with Firebase filtered list
        itemBuilder: (_, i) {
          return _requestCard();
        },
      ),
    );
  }

  Widget _requestCard() {
    final bool isEmergency = true; // later: dynamic from Firebase

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
                      child: const Text(
                        'O+',
                        style: TextStyle(
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
                    color: isEmergency ? Colors.red.withOpacity(.15) : Colors.orange.withOpacity(.15),
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

            _infoRow(Icons.person_outline, 'Patient', 'Rahim Uddin'),
            _infoRow(Icons.medical_information_outlined, 'Problem', 'Accident – heavy bleeding'),
            _infoRow(Icons.bloodtype_outlined, 'Required Units', '2 Bags'),
            _infoRow(Icons.local_hospital_outlined, 'Hospital', 'Popular Medical College Hospital'),
            _infoRow(Icons.location_on_outlined, 'Location', 'Dhanmondi, Dhaka'),
            _infoRow(Icons.calendar_month_outlined, 'Date & Time', '15 Feb 2026 • 10:30 AM'),
            _infoRow(Icons.note_outlined, 'Notes', 'Need blood urgently before surgery'),

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
                  makePhoneCall('017XXXXXXXX');
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
    } else {
      // ignore: avoid_print
      print('Could not launch $phoneNumber');
    }
  }
}

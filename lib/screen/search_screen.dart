import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedBloodGroup = 'O+';

  final List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  Future<void> makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Donor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🩸 SELECT BLOOD GROUP
            const Text(
              'Select Blood Group',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              children: bloodGroups.map((group) {
                return ChoiceChip(
                  label: Text(group),
                  selected: selectedBloodGroup == group,
                  onSelected: (_) {
                    setState(() {
                      selectedBloodGroup = group;
                    });
                    // TODO: Firebase query trigger here
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// 🔍 RESULT LABEL
            Text(
              'Available Donors for $selectedBloodGroup',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// 👥 DONOR LIST
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Firebase data length later
                itemBuilder: (_, i) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          /// 👤 AVATAR
                          const CircleAvatar(
                            radius: 22,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),

                          /// INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Available Donor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'O+ • CSE • DIU',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 📞 CALL
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () {
                              makePhoneCall('017XXXXXXXX');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

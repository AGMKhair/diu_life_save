import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedBloodGroup = 'A+';

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

  Future<void> makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }


  Stream<List<DonorModel>> donorStream(String bloodGroup) {
    return FirebaseFirestore.instance
          .collection('users')
        .where('bloodGroup', isEqualTo: bloodGroup)
        // .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DonorModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Donor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Blood Group',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 5,
              runSpacing: 5,
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
                  label: Text(
                    bg,
                    style: TextStyle(
                      color: selectedBloodGroup == bg
                          ? Colors.white
                          : AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selectedBloodGroup == bg,
                  selectedColor: AppColors.primaryRed,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (_) {
                    setState(() {
                      selectedBloodGroup = bg;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// 🔍 RESULT LABEL
            Text(
              'Available Donors for $selectedBloodGroup',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            /// 👥 DONOR LIST
            Expanded(
              child: StreamBuilder<List<DonorModel>>(
                stream: donorStream(selectedBloodGroup),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No donors found in your area"),
                    );
                  }

                  final donors = snapshot.data!;

                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (_, i) {
                      final donor = donors[i];
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
                                  children: [
                                    Text(
                                      donor.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${donor.bloodGroup} • ${donor.department} • ${donor.area}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// 📞 CALL
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  makePhoneCall(donor.phone);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

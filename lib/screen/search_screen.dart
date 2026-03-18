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
  // ১. ডিফল্টভাবে 'All' সিলেক্ট করা থাকবে
  String selectedBloodGroup = 'All';

  final List<String> bloodGroups = [
    'All', // 'All' অপশন যোগ করা হয়েছে
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  Future<void> makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // স্ট্রিম ফাংশনটি আপডেট করা হয়েছে
  Stream<List<DonorModel>> donorStream(String bloodGroup) {
    Query query = FirebaseFirestore.instance.collection('users');

    // ব্লাড গ্রুপ 'All' না হলে ফিল্টার করবে
    if (bloodGroup != 'All') {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return query.snapshots().map(
          (snapshot) {
        final now = DateTime.now();
        return snapshot.docs
            .map((doc) => DonorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .where((donor) {
          // ২. ফিল্টার লজিক:
          // (a) isAvailable ট্রু হতে হবে
          // (b) lastDonationDate নেই (নতুন ডোনার) অথবা ১২০ দিন (৪ মাস) পার হয়েছে

          bool isTimeReady = true;
          if (donor.lastDonationDate != null) {
            final difference = now.difference(donor.lastDonationDate!).inDays;
            isTimeReady = difference >= 120; // ৪ মাস = ১২০ দিন ধরা হয়েছে
          }

          return donor.isAvailable && isTimeReady;
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Donor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text(
              'Available Donors: $selectedBloodGroup',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<DonorModel>>(
                stream: donorStream(selectedBloodGroup),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No donors available at this moment"),
                    );
                  }

                  final donors = snapshot.data!;

                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (_, i) {
                      final donor = donors[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                            child: Text(
                              donor.bloodGroup,
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(donor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${donor.department} • ${donor.area}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => makePhoneCall(donor.phone),
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
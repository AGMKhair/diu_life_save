import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/donor_model.dart';
import 'package:diu_life_save/screen/profile/edit_profile_screen.dart';
import 'package:diu_life_save/screen/post/post_details_screen.dart';
import 'package:diu_life_save/screen/splash_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// 🔹 Edit screen এ পাঠানোর জন্য আগের method — একদম intact
  Future<DonorModel?> getProfileData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      return DonorModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          /// ✏️ Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.diuGreen),
            onPressed: () async {
              final model = await getProfileData();
              if (model != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(model: model),
                  ),
                );
              }
            },
          ),

          /// 📝 Post
          IconButton(
            icon: const Icon(Icons.post_add, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PostDetailsScreen(),
                ),
              );
            },
          ),

          /// 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primaryRed),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SplashScreen()),
              );
            },
          ),
        ],
      ),

      /// 🔥 LIVE PROFILE STREAM
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// 👤 BASIC INFO
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: data.profileImage != null &&
                                data.profileImage!.isNotEmpty
                                ? NetworkImage(data.profileImage!)
                                : null,
                            child: data.profileImage == null
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.name.isNotEmpty ? data.name : "—",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _badge(data.bloodGroup.isNotEmpty
                              ? data.bloodGroup
                              : "—"),
                          const SizedBox(height: 10),
                          _availabilityBadge(data.isAvailable),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// 📋 DETAILS
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoTile(Icons.phone, 'Mobile', data.phone),
                        const Divider(),
                        _infoTile(Icons.school, 'Department', data.department),

                        const Divider(),
                        _infoTile(
                          Icons.calendar_month,
                          'Last Donation',
                          data.lastDonationDate != null
                              ? DateFormat('dd MMM yyyy')
                              .format(data.lastDonationDate!)
                              : 'Not donated yet',
                        ),
                        const Divider(),
                        _infoTile(Icons.location_on, 'Area', data.area),

                        const Divider(),
                        _infoTile(Icons.cake, 'Age', '${data.age} years'),
                        const Divider(),
                        _infoTile(
                            Icons.monitor_weight, 'Weight', '${data.weight} kg'),



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

  /// 🔴 Blood group badge
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🟢 Availability
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

  /// ℹ️ Info row
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
                Text(title,
                    style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "—",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

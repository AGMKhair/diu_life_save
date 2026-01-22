import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/blood_request_model.dart';
import 'package:diu_life_save/screen/post/post_edit_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Blood Requests',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have not posted any request yet'),
            );
          }

          final posts = snapshot.data!.docs
              .map((doc) => BloodRequestModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (_, index) {
              final post = posts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${post.bloodGroup} • ${post.units} Units',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (post.isEmergency)
                                const Chip(
                                  label: Text(
                                    'E',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditPostScreen(model: post),
                                    ),
                                  );
                                },
                              ),

                              /// 🔴 DELETE BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep,
                                  color: AppColors.primaryRed,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text('Delete Post'),
                                        content: const Text(
                                          'Are you sure you want to delete this request?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(post.id)
                                        .delete();

                                    AppSnackBar.showSuccess(
                                      context,
                                      message: 'Post deleted successfully',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Patient: ${post.patientName}'),
                      Text('Hospital: ${post.hospital}'),
                      Text('Location: ${post.location}'),
                      Text('Phone: ${post.phone}'),
                      Text('Problem: ${post.problem}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

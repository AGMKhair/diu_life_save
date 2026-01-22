import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diu_life_save/model/blood_request_model.dart';
import 'package:diu_life_save/screen/post/create_post_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/function.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewRequestScreen extends StatefulWidget {
  const ViewRequestScreen({super.key});

  @override
  State<ViewRequestScreen> createState() => _ViewRequestScreenState();
}

class _ViewRequestScreenState extends State<ViewRequestScreen> {
  String selectedBloodGroup = 'All';
  DateTime? selectedDate;

  final List<String> bloodGroups = [
    'All',
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Requests',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// BLOOD GROUP FILTER
                    Wrap(
                      spacing: 4,
                      // runSpacing: 4,
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

                    const SizedBox(height: 5),

                    /// DATE FILTER
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedDate == null
                                        ? 'Filter by date'
                                        : DateFormat('dd MMM yyyy')
                                        .format(selectedDate!),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                              selectedBloodGroup = 'All';
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 📋 REQUEST LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No requests found"));
                }

                final allPosts = snapshot.data!.docs
                    .map((e) => BloodRequestModel.fromMap(
                    e.data() as Map<String, dynamic>, e.id))
                    .toList();

                // FILTER
                final filteredPosts = allPosts.where((post) {
                  final matchBlood = selectedBloodGroup == 'All' ||
                      post.bloodGroup == selectedBloodGroup;

                  final matchDate = selectedDate == null ||
                      DateFormat('dd-MM-yyyy')
                          .format(post.requiredDateTime) ==
                          DateFormat('dd-MM-yyyy').format(selectedDate!);

                  return matchBlood && matchDate;
                }).toList();

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text("No requests found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (_, i) {
                    return _requestCard(filteredPosts[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 🔴 SINGLE REQUEST CARD
  Widget _requestCard(BloodRequestModel post) {
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.bloodGroup,
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.isEmergency
                        ? Colors.red.withOpacity(.15)
                        : Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.isEmergency ? 'Emergency' : 'Pending',
                    style: TextStyle(
                      color: post.isEmergency ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🧑 PATIENT NAME
            _infoRow(Icons.person_outline, 'Patient', post.patientName),

            /// 🩺 PROBLEM
            _infoRow(Icons.medical_information_outlined, 'Problem', post.problem),

            /// 🧪 UNITS
            _infoRow(
              Icons.bloodtype_outlined,
              'Required Units',
              '${post.units} Bags',
            ),

            /// 🏥 HOSPITAL
            _infoRow(Icons.local_hospital_outlined, 'Hospital', post.hospital),

            /// 📍 LOCATION
            _infoRow(Icons.location_on_outlined, 'Location', post.location),

            /// 📅 DATE & TIME
            _infoRow(
              Icons.calendar_month_outlined,
              'Date & Time',
              DateFormat('dd MMM yyyy • hh:mm a')
                  .format(post.requiredDateTime),
            ),

            /// 📝 NOTES (Optional)
            _infoRow(Icons.note_outlined, 'Notes', post.note),

            const SizedBox(height: 16),

            /// 📞 CALL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Requester'),
                onPressed: () {
                  makePhoneCall(post.phone);
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
}

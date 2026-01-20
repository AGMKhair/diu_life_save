import 'package:diu_life_save/screen/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:diu_life_save/util/function.dart';
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
          /// 🔍 FILTER SECTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// BLOOD GROUP FILTER
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
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

                    const SizedBox(height: 12),

                    /// DATE FILTER
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // later: Firebase filtered list
              itemBuilder: (_, i) {
                return _requestCard();
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
        backgroundColor: AppColors.primaryRed, // Red color
        child: const Icon(
          Icons.add, // Button icon
          color: Colors.white,
        ),
      ),
    );
  }

  /// 🔴 SINGLE REQUEST CARD
  Widget _requestCard() {
    final bool isEmergency = true; // later from Firebase
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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

            /// 🧑 PATIENT NAME
            _infoRow(Icons.person_outline, 'Patient', 'Rahim Uddin'),

            /// 🩺 PROBLEM
            _infoRow(
              Icons.medical_information_outlined,
              'Problem',
              'Accident – heavy bleeding',
            ),

            /// 🧪 UNITS
            _infoRow(
              Icons.bloodtype_outlined,
              'Required Units',
              '2 Bags',
            ),

            /// 🏥 HOSPITAL
            _infoRow(
              Icons.local_hospital_outlined,
              'Hospital',
              'Popular Medical College Hospital',
            ),

            /// 📍 LOCATION
            _infoRow(
              Icons.location_on_outlined,
              'Location',
              'Dhanmondi, Dhaka',
            ),

            /// 📅 DATE & TIME
            _infoRow(
              Icons.calendar_month_outlined,
              'Date & Time',
              '15 Feb 2026 • 10:30 AM',
            ),

            /// 📝 NOTES (Optional)
            _infoRow(
              Icons.note_outlined,
              'Notes',
              'Need blood urgently before surgery',
            ),

            const SizedBox(height: 16),

            /// 📞 CALL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call Requester'),
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

}

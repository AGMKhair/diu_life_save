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
    );
  }

  /// 🔴 SINGLE REQUEST CARD
  Widget _requestCard() {
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
            /// TOP ROW
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

                /// STATUS
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// LOCATION
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 18),
                SizedBox(width: 6),
                Text('DIU, Dhaka'),
              ],
            ),

            const SizedBox(height: 8),

            /// REQUIRED DATE
            Row(
              children: const [
                Icon(Icons.calendar_month_outlined, size: 18),
                SizedBox(width: 6),
                Text(
                  'Required by: 15 Feb 2026',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ACTION
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
}

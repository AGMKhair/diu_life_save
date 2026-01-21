import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  final String id;
  final String name;
  final String phone;
  final String department;
  final String area;
  final String bloodGroup;
  final DateTime? lastDonationDate;

  DonorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.department,
    required this.area,
    required this.bloodGroup,
    this.lastDonationDate,
  });

  factory DonorModel.fromMap(String id, Map<String, dynamic> map) {
    return DonorModel(
      id: id,
      name: map['name'],
      phone: map['phone'],
      department: map['department'],
      area: map['area'],
      bloodGroup: map['bloodGroup'],
      lastDonationDate:
      map['lastDonationDate'] != null
          ? (map['lastDonationDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'department': department,
      'area': area,
      'bloodGroup': bloodGroup,
      'lastDonationDate':
      lastDonationDate != null ? Timestamp.fromDate(lastDonationDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

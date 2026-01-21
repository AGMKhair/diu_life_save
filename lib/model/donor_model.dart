import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  final String id;
  final String name;
  final String phone;
  final String department;
  final int age;
  final int weight;
  final String bloodGroup;
  final String area;
  final bool isAvailable;
  final DateTime? lastDonationDate;
  final String? profileImage;

  DonorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.department,
    required this.age,
    required this.weight,
    required this.bloodGroup,
    required this.area,
    required this.isAvailable,
    this.lastDonationDate,
    this.profileImage,
  });

  factory DonorModel.fromMap(String id, Map<String, dynamic> map) {
    return DonorModel(
      id: id,
      name: map['name'] ?? "",
      phone: map['phone'] ?? "",
      department: map['department'] ?? "",
      age: (map['age'] ?? 0).toInt(),
      weight: (map['weight'] ?? 0).toInt(),
      bloodGroup: map['bloodGroup'] ?? "",
      area: map['area'] ?? "",
      isAvailable: map['isAvailable'] ?? false,
      lastDonationDate: map['lastDonationDate'] != null
          ? (map['lastDonationDate'] as Timestamp).toDate()
          : null,
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "department": department,
      "age": age,
      "weight": weight,
      "bloodGroup": bloodGroup,
      "area": area,
      "isAvailable": isAvailable,
      "lastDonationDate": lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      "profileImage": profileImage,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }
}

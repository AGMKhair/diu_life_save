import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestModel {
  final String id;
  final String uid;
  final String patientName;
  final String problem;
  final String bloodGroup;
  final int units;
  final String hospital;
  final String location;
  final String phone;
  final String note;
  final bool isEmergency;
  final DateTime requiredDateTime;
  final DateTime createdAt;
  final DateTime expireAt;

  BloodRequestModel({
    required this.id,
    required this.uid,
    required this.patientName,
    required this.problem,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.location,
    required this.phone,
    required this.note,
    required this.isEmergency,
    required this.requiredDateTime,
    required this.createdAt,
    required this.expireAt,
  });

  factory BloodRequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return BloodRequestModel(
      id: docId,
      uid: map['uid'] ?? "",
      patientName: map['patientName'] ?? "",
      problem: map['problem'] ?? "",
      bloodGroup: map['bloodGroup'] ?? "O+",
      units: map['units'] ?? 0,
      hospital: map['hospital'] ?? "",
      location: map['location'] ?? "",
      phone: map['phone'] ?? "",
      note: map['note'] ?? "",
      isEmergency: map['isEmergency'] ?? false,
      requiredDateTime:
      (map['requiredDateTime'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expireAt: (map['expireAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "patientName": patientName,
      "problem": problem,
      "bloodGroup": bloodGroup,
      "units": units,
      "hospital": hospital,
      "location": location,
      "phone": phone,
      "note": note,
      "isEmergency": isEmergency,
      "requiredDateTime": Timestamp.fromDate(requiredDateTime),
      "createdAt": Timestamp.fromDate(createdAt),
      "expireAt": Timestamp.fromDate(expireAt),
    };
  }
}

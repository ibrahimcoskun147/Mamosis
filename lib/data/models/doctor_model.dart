import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Doctor data model for Firestore
class DoctorModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String organisation;
  final String phone;
  final List<String> patients; // List of patient IDs
  final bool isPro; // Pro subscription status

  const DoctorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.organisation,
    required this.phone,
    this.patients = const [],
    this.isPro = false,
  });

  /// Full name getter with title
  String get fullName => '$firstName $lastName';
  
  /// Display name with Dr. prefix
  String get displayName => 'Dr. $fullName';

  /// Factory to create from Firestore document
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      organisation: data['organisation'] ?? '',
      phone: data['phone'] ?? '',
      patients: List<String>.from(data['patients'] ?? []),
      isPro: data['isPro'] ?? false,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'organisation': organisation,
      'phone': phone,
      'patients': patients,
      'isPro': isPro,
    };
  }

  /// Copy with method
  DoctorModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? organisation,
    String? phone,
    List<String>? patients,
    bool? isPro,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      organisation: organisation ?? this.organisation,
      phone: phone ?? this.phone,
      patients: patients ?? this.patients,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, organisation, phone, patients, isPro];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Patient data model for Firestore
class PatientModel extends Equatable {
  final String id; // Firestore document ID
  final String patientId; // User-entered patient ID 
  final String firstName;
  final String lastName;
  final String status; // 'Positive' | 'Negative'
  final String imageUrl;
  final String riskDescription;
  final DateTime createdAt;

  const PatientModel({
    required this.id,
    this.patientId = '',
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.imageUrl,
    required this.riskDescription,
    required this.createdAt,
  });

  /// Full name getter
  String get fullName => '$firstName $lastName';

  /// Date formatted as DD/MM/YYYY
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  /// Check if status is Positive
  bool get isPositive => status.toLowerCase() == 'positive';

  /// Factory to create from Firestore document
  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      status: data['status'] ?? 'Negative',
      imageUrl: data['imageUrl'] ?? '',
      riskDescription: data['riskDescription'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'firstName': firstName,
      'lastName': lastName,
      'status': status,
      'imageUrl': imageUrl,
      'riskDescription': riskDescription,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with method
  PatientModel copyWith({
    String? id,
    String? patientId,
    String? firstName,
    String? lastName,
    String? status,
    String? imageUrl,
    String? riskDescription,
    DateTime? createdAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      riskDescription: riskDescription ?? this.riskDescription,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, patientId, firstName, lastName, status, imageUrl, riskDescription, createdAt];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

/// Firestore datasource for patient data operations
class PatientDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _patientsCollection =>
      _firestore.collection('patients');

  /// Get all patients for a specific doctor (by patient IDs)
  Future<List<PatientModel>> getAllPatientsByIds(List<String> patientIds) async {
    if (patientIds.isEmpty) return [];
    
    try {
      // Firestore 'whereIn' is limited to 30 items, handle in batches
      final List<PatientModel> allPatients = [];
      
      for (int i = 0; i < patientIds.length; i += 30) {
        final batchIds = patientIds.skip(i).take(30).toList();
        final snapshot = await _patientsCollection
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        
        allPatients.addAll(
          snapshot.docs.map((doc) => PatientModel.fromFirestore(doc)),
        );
      }
      
      // Sort by createdAt descending
      allPatients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allPatients;
    } catch (e) {
      throw Exception('Failed to fetch patients: $e');
    }
  }

  /// Get recent patients for a specific doctor (by patient IDs)
  Future<List<PatientModel>> getRecentPatientsByIds(List<String> patientIds, {int limit = 5}) async {
    if (patientIds.isEmpty) return [];
    
    try {
      final allPatients = await getAllPatientsByIds(patientIds);
      return allPatients.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent patients: $e');
    }
  }

  /// Get patient by ID
  Future<PatientModel?> getPatientById(String id) async {
    try {
      final doc = await _patientsCollection.doc(id).get();
      if (doc.exists) {
        return PatientModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch patient: $e');
    }
  }

  /// Add new patient and return the patient with ID
  Future<PatientModel> addPatient(PatientModel patient) async {
    try {
      final docRef = await _patientsCollection.add(patient.toFirestore());
      return patient.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  /// Get patient statistics for a specific doctor (by patient IDs)
  Future<Map<String, int>> getPatientStatsByIds(List<String> patientIds) async {
    if (patientIds.isEmpty) {
      return {'total': 0, 'positive': 0, 'negative': 0};
    }
    
    try {
      final patients = await getAllPatientsByIds(patientIds);
      
      final int total = patients.length;
      final int positive = patients.where((p) => p.isPositive).length;
      final int negative = total - positive;
      
      return {
        'total': total,
        'positive': positive,
        'negative': negative,
      };
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  /// Stream of patients for real-time updates (filtered by IDs)
  Stream<List<PatientModel>> watchPatientsByIds(List<String> patientIds) {
    if (patientIds.isEmpty) {
      return Stream.value([]);
    }
    
    // For simplicity, watch only first 30 IDs (Firestore limit)
    final watchIds = patientIds.take(30).toList();
    
    return _patientsCollection
        .where(FieldPath.documentId, whereIn: watchIds)
        .snapshots()
        .map((snapshot) {
          final patients = snapshot.docs
              .map((doc) => PatientModel.fromFirestore(doc))
              .toList();
          patients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return patients;
        });
  }
}

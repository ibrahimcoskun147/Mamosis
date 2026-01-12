import '../../data/models/patient_model.dart';

/// Abstract repository interface for patient operations
abstract class PatientRepository {
  /// Get all patients for a doctor (by patient IDs)
  Future<List<PatientModel>> getAllPatientsByIds(List<String> patientIds);
  
  /// Get recent patients for a doctor (by patient IDs)
  Future<List<PatientModel>> getRecentPatientsByIds(List<String> patientIds, {int limit = 5});
  
  /// Get patient by ID
  Future<PatientModel?> getPatientById(String id);
  
  /// Add new patient
  Future<PatientModel> addPatient(PatientModel patient);
  
  /// Get patient statistics for a doctor (by patient IDs)
  Future<Map<String, int>> getPatientStatsByIds(List<String> patientIds);
  
  /// Watch patients stream for a doctor (by patient IDs)
  Stream<List<PatientModel>> watchPatientsByIds(List<String> patientIds);
}

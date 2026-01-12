import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_datasource.dart';
import '../models/patient_model.dart';

/// Implementation of PatientRepository
class PatientRepositoryImpl implements PatientRepository {
  final PatientDatasource _datasource;

  PatientRepositoryImpl(this._datasource);

  @override
  Future<List<PatientModel>> getAllPatientsByIds(List<String> patientIds) {
    return _datasource.getAllPatientsByIds(patientIds);
  }

  @override
  Future<List<PatientModel>> getRecentPatientsByIds(List<String> patientIds, {int limit = 5}) {
    return _datasource.getRecentPatientsByIds(patientIds, limit: limit);
  }

  @override
  Future<PatientModel?> getPatientById(String id) {
    return _datasource.getPatientById(id);
  }

  @override
  Future<PatientModel> addPatient(PatientModel patient) {
    return _datasource.addPatient(patient);
  }

  @override
  Future<Map<String, int>> getPatientStatsByIds(List<String> patientIds) {
    return _datasource.getPatientStatsByIds(patientIds);
  }

  @override
  Stream<List<PatientModel>> watchPatientsByIds(List<String> patientIds) {
    return _datasource.watchPatientsByIds(patientIds);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/doctor_model.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<bool> isPhoneAllowed(String phoneNumber) {
    return _datasource.isPhoneAllowed(phoneNumber);
  }

  @override
  Future<User?> signInAnonymously() {
    return _datasource.signInAnonymously();
  }

  @override
  Future<DoctorModel?> getDoctorByPhone(String phoneNumber) {
    return _datasource.getDoctorByPhone(phoneNumber);
  }

  @override
  Future<DoctorModel?> getDoctorById(String doctorId) {
    return _datasource.getDoctorById(doctorId);
  }

  @override
  Future<void> addPatientToDoctor(String doctorId, String patientId) {
    return _datasource.addPatientToDoctor(doctorId, patientId);
  }

  @override
  User? get currentUser => _datasource.currentUser;

  @override
  bool get isAuthenticated => _datasource.isAuthenticated;

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;
}

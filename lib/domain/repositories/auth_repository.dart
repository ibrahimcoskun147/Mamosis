import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/doctor_model.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Check if phone number is allowed
  Future<bool> isPhoneAllowed(String phoneNumber);
  
  /// Sign in anonymously
  Future<User?> signInAnonymously();
  
  /// Get doctor by phone number
  Future<DoctorModel?> getDoctorByPhone(String phoneNumber);
  
  /// Get doctor by ID
  Future<DoctorModel?> getDoctorById(String doctorId);
  
  /// Add patient ID to doctor's patients array
  Future<void> addPatientToDoctor(String doctorId, String patientId);
  
  /// Get current user
  User? get currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated;
  
  /// Sign out
  Future<void> signOut();
  
  /// Auth state changes stream
  Stream<User?> get authStateChanges;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';

/// Firestore datasource for authentication and doctor data
class AuthDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _doctorsCollection =>
      _firestore.collection('doctors');

  /// Check if phone number is registered in doctors collection
  Future<bool> isPhoneAllowed(String phoneNumber) async {
    try {
      // Clean phone number - remove spaces and non-digits except +
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Check if doctor exists with this phone
      final snapshot = await _doctorsCollection
          .where('phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check phone: $e');
    }
  }

  /// Sign in anonymously (used after phone validation)
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Get doctor by phone number
  Future<DoctorModel?> getDoctorByPhone(String phoneNumber) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      final snapshot = await _doctorsCollection
          .where('phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return DoctorModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }

  /// Get doctor by ID
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final doc = await _doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        return DoctorModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }

  /// Add patient ID to doctor's patients array
  Future<void> addPatientToDoctor(String doctorId, String patientId) async {
    try {
      await _doctorsCollection.doc(doctorId).update({
        'patients': FieldValue.arrayUnion([patientId]),
      });
    } catch (e) {
      throw Exception('Failed to update doctor patients: $e');
    }
  }

  /// Get current auth user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

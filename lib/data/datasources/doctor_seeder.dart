import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/logger.dart';

/// Utility class to seed doctors to Firestore
class DoctorSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// List of doctors to seed
  final List<Map<String, dynamic>> _doctors = [
    {
      'firstName': 'Ahmet',
      'lastName': 'Yılmaz',
      'organisation': 'Mamosis Clinic',
      'phone': '+905551234567',
    },
    {
      'firstName': 'Mehmet',
      'lastName': 'Demir',
      'organisation': 'Mamosis Clinic',
      'phone': '+905559876543',
    },
    {
      'firstName': 'Ayşe',
      'lastName': 'Kaya',
      'organisation': 'Mamosis Clinic',
      'phone': '+905551112233',
    },
  ];

  /// Seed doctors to Firestore
  Future<void> seedDoctors() async {
    Logger.i('[DoctorSeeder] Starting to seed ${_doctors.length} doctors...', 'DoctorSeeder');
    
    for (final doctor in _doctors) {
      try {
        final String phone = doctor['phone'];
        Logger.d('[DoctorSeeder] Checking if doctor with phone $phone exists...', 'DoctorSeeder');
        
        // Check if doctor with this phone already exists
        final QuerySnapshot existingDocs = await _firestore
            .collection('doctors')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (existingDocs.docs.isEmpty) {
          Logger.i('[DoctorSeeder] Adding doctor: ${doctor['firstName']} ${doctor['lastName']}', 'DoctorSeeder');
          await _firestore.collection('doctors').add({
            ...doctor,
            'createdAt': FieldValue.serverTimestamp(),
          });
          Logger.i('[DoctorSeeder] ✓ Added: ${doctor['firstName']} ${doctor['lastName']}', 'DoctorSeeder');
        } else {
          Logger.d('[DoctorSeeder] Already exists: ${doctor['firstName']} ${doctor['lastName']}', 'DoctorSeeder');
        }
      } catch (e) {
        Logger.e('[DoctorSeeder] ✗ Error: $e', e, null, 'DoctorSeeder');
      }
    }
    
    Logger.i('[DoctorSeeder] Seeding complete!', 'DoctorSeeder');
  }

  /// Get all doctor phone numbers (for local validation)
  List<String> getAllPhoneNumbers() {
    return _doctors.map((d) => d['phone'] as String).toList();
  }
}

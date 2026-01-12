import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/patient_repository.dart';

part 'home_state.dart';

/// Home Cubit for dashboard data
class HomeCubit extends Cubit<HomeState> {
  final PatientRepository _patientRepository;
  final AuthRepository _authRepository;

  HomeCubit({
    required PatientRepository patientRepository,
    required AuthRepository authRepository,
  })  : _patientRepository = patientRepository,
        _authRepository = authRepository,
        super(const HomeState());

  /// Load all dashboard data
  Future<void> loadDashboard({String? phoneNumber, DoctorModel? doctor}) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Load doctor info if phone provided and doctor not passed
      DoctorModel? currentDoctor = doctor;
      if (currentDoctor == null && phoneNumber != null && phoneNumber.isNotEmpty) {
        currentDoctor = await _authRepository.getDoctorByPhone(phoneNumber);
      }

      // Get patient IDs from doctor
      final patientIds = currentDoctor?.patients ?? [];

      // Load stats for this doctor's patients
      final stats = await _patientRepository.getPatientStatsByIds(patientIds);

      // Load recent patients for this doctor
      final recentPatients = await _patientRepository.getRecentPatientsByIds(patientIds, limit: 5);

      emit(state.copyWith(
        status: HomeStatus.loaded,
        doctor: currentDoctor,
        totalCount: stats['total'] ?? 0,
        positiveCount: stats['positive'] ?? 0,
        negativeCount: stats['negative'] ?? 0,
        recentPatients: recentPatients,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Failed to load dashboard: $e',
      ));
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    try {
      final patientIds = state.doctor?.patients ?? [];
      final stats = await _patientRepository.getPatientStatsByIds(patientIds);
      final recentPatients = await _patientRepository.getRecentPatientsByIds(patientIds, limit: 5);

      emit(state.copyWith(
        totalCount: stats['total'] ?? 0,
        positiveCount: stats['positive'] ?? 0,
        negativeCount: stats['negative'] ?? 0,
        recentPatients: recentPatients,
      ));
    } catch (e) {
      // Silent refresh failure
    }
  }

  /// Set doctor info and reload
  Future<void> setDoctor(DoctorModel doctor) async {
    emit(state.copyWith(doctor: doctor));
    await loadDashboard(doctor: doctor);
  }

  /// Update doctor after adding patient
  void updateDoctorPatients(List<String> newPatients) {
    if (state.doctor != null) {
      emit(state.copyWith(
        doctor: state.doctor!.copyWith(patients: newPatients),
      ));
    }
  }
}

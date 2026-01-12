import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/patient_model.dart';
import '../../../domain/repositories/patient_repository.dart';

part 'patient_list_state.dart';

/// Patient List Cubit for displaying all patients for a doctor
class PatientListCubit extends Cubit<PatientListState> {
  final PatientRepository _patientRepository;

  PatientListCubit(this._patientRepository) : super(const PatientListState());

  /// Load all patients for a doctor by their patient IDs
  Future<void> loadPatients(List<String> patientIds) async {
    emit(state.copyWith(status: PatientListStatus.loading));

    try {
      final patients = await _patientRepository.getAllPatientsByIds(patientIds);
      
      emit(state.copyWith(
        status: PatientListStatus.loaded,
        patients: patients,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientListStatus.error,
        errorMessage: 'Failed to load patients: $e',
      ));
    }
  }

  /// Refresh patients list with loading indicator
  Future<void> refresh(List<String> patientIds) async {
    emit(state.copyWith(status: PatientListStatus.refreshing));
    
    try {
      final patients = await _patientRepository.getAllPatientsByIds(patientIds);
      emit(state.copyWith(
        status: PatientListStatus.loaded,
        patients: patients,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientListStatus.loaded,
        errorMessage: 'Failed to refresh: $e',
      ));
    }
  }

  /// Get patient by ID
  PatientModel? getPatientById(String id) {
    try {
      return state.patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

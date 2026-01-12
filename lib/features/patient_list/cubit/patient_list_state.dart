part of 'patient_list_cubit.dart';

enum PatientListStatus {
  initial,
  loading,
  refreshing, // For pull-to-refresh
  loaded,
  error,
}

class PatientListState extends Equatable {
  final PatientListStatus status;
  final List<PatientModel> patients;
  final String errorMessage;
  final int currentPage;

  const PatientListState({
    this.status = PatientListStatus.initial,
    this.patients = const [],
    this.errorMessage = '',
    this.currentPage = 1,
  });

  PatientListState copyWith({
    PatientListStatus? status,
    List<PatientModel>? patients,
    String? errorMessage,
    int? currentPage,
  }) {
    return PatientListState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, patients, errorMessage, currentPage];
}

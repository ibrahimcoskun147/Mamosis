part of 'home_cubit.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final DoctorModel? doctor;
  final int totalCount;
  final int positiveCount;
  final int negativeCount;
  final List<PatientModel> recentPatients;
  final String errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.doctor,
    this.totalCount = 0,
    this.positiveCount = 0,
    this.negativeCount = 0,
    this.recentPatients = const [],
    this.errorMessage = '',
  });

  HomeState copyWith({
    HomeStatus? status,
    DoctorModel? doctor,
    int? totalCount,
    int? positiveCount,
    int? negativeCount,
    List<PatientModel>? recentPatients,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      doctor: doctor ?? this.doctor,
      totalCount: totalCount ?? this.totalCount,
      positiveCount: positiveCount ?? this.positiveCount,
      negativeCount: negativeCount ?? this.negativeCount,
      recentPatients: recentPatients ?? this.recentPatients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctor,
        totalCount,
        positiveCount,
        negativeCount,
        recentPatients,
        errorMessage,
      ];
}

part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final DoctorModel? doctor;
  final String phoneNumber;
  final String errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.doctor,
    this.phoneNumber = '',
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? status,
    DoctorModel? doctor,
    String? phoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      doctor: doctor ?? this.doctor,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, doctor, phoneNumber, errorMessage];
}

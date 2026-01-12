import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/doctor_model.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

/// Auth Cubit for handling login with phone validation
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  
  AuthCubit(this._authRepository) : super(const AuthState());

  /// Check phone and attempt login
  Future<void> login(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid phone number',
      ));
      return;
    }

    final fullPhone = '+90$phoneNumber';

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isAllowed = await _authRepository.isPhoneAllowed(fullPhone);
      
      if (!isAllowed) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Number not registered',
        ));
        return;
      }

      await _authRepository.signInAnonymously();
      
      final doctor = await _authRepository.getDoctorByPhone(fullPhone);
      
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        doctor: doctor,
        phoneNumber: fullPhone,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed. Please try again.',
      ));
    }
  }

  /// Check if already authenticated
  Future<void> checkAuthStatus() async {
    if (_authRepository.isAuthenticated) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      doctor: null,
      phoneNumber: '',
    ));
  }

  void clearError() {
    emit(state.copyWith(
      status: AuthStatus.initial,
      errorMessage: '',
    ));
  }
}

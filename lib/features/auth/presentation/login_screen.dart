import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../../../core/navigation/main_navigation.dart';

/// Login screen with phone number validation
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late final AuthCubit _authCubit;
  bool _isPhoneValid = false;
  List<Map<String, dynamic>> _registeredDoctors = [];
  bool _isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _phoneController.addListener(_onPhoneChanged);
    _loadRegisteredDoctors();
  }

  Future<void> _loadRegisteredDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .get();
      
      setState(() {
        _registeredDoctors = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': '${data['firstName']} ${data['lastName']}',
            'phone': data['phone'] ?? '',
          };
        }).toList();
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDoctors = false;
      });
    }
  }

  void _onPhoneChanged() {
    final isValid = _phoneController.text.trim().length >= 10;
    if (isValid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final phone = _phoneController.text.trim();
    _authCubit.login(phone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainNavigation(
                  phoneNumber: state.phoneNumber,
                  doctor: state.doctor,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 32,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '1.0',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.h2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          AppStrings.loginTitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Phone Input
                        CustomTextField(
                          controller: _phoneController,
                          prefix: AppStrings.phonePrefix,
                          hintText: AppStrings.phoneHint,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          errorText: state.status == AuthStatus.error
                              ? state.errorMessage
                              : null,
                        ),
                        const SizedBox(height: 24),
                        // Continue Button
                        PrimaryButton(
                          text: AppStrings.continueButton,
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: _isPhoneValid ? _onContinue : null,
                        ),
                        const SizedBox(height: 32),
                        // Registered Doctors Info
                        _buildRegisteredDoctorsInfo(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisteredDoctorsInfo() {
    if (_isLoadingDoctors) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_registeredDoctors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Registered Doctors',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._registeredDoctors.map((doctor) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor['name'],
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Text(
                  _formatPhone(doctor['phone']),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatPhone(String phone) {
    // +905551234567 -> 555 123 4567
    if (phone.startsWith('+90') && phone.length >= 13) {
      final digits = phone.substring(3); // Remove +90
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return phone;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/doctor_model.dart';
import '../cubit/scan_cubit.dart';

/// Result screen showing mammogram analysis and save form
class ResultScreen extends StatefulWidget {
  final ScanCubit scanCubit;
  final DoctorModel doctor;
  final Function(String patientId)? onPatientSaved;

  const ResultScreen({
    super.key,
    required this.scanCubit,
    required this.doctor,
    this.onPatientSaved,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _savePatient() {
    if (_nameController.text.isEmpty || _surnameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and surname')),
      );
      return;
    }

    widget.scanCubit.savePatient(
      firstName: _nameController.text.trim(),
      lastName: _surnameController.text.trim(),
      doctorId: widget.doctor.id,
      patientId: _idController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.scanCubit,
      child: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state.status == ScanStatus.saved) {
            // Notify parent about the new patient
            if (state.savedPatientId != null) {
              widget.onPatientSaved?.call(state.savedPatientId!);
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Patient saved successfully')),
            );
          } else if (state.status == ScanStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppStrings.result,
                          style: AppTextStyles.h4,
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Image Display
                          if (state.selectedImage != null)
                            Container(
                              width: double.infinity,
                              height: 250,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.file(
                                      state.selectedImage!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Risk Description
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: AppColors.surface,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: state.analysisResult?.isPositive == true
                                      ? AppColors.negative
                                      : AppColors.positive,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.analysisResult?.riskDescription ??
                                        AppStrings.riskyMammogram,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Save Patient Form
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.savePatient,
                                      style: AppTextStyles.labelLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: _nameController,
                                  hintText: AppStrings.patientName,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: _surnameController,
                                  hintText: AppStrings.patientSurname,
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: _idController,
                                  hintText: AppStrings.patientIdOptional,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 20),
                                PrimaryButton(
                                  text: AppStrings.savePatient,
                                  isLoading: state.status == ScanStatus.saving,
                                  onPressed: _savePatient,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

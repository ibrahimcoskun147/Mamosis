import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/doctor_model.dart';
import '../cubit/scan_cubit.dart';
import 'result_screen.dart';

/// Analyzing screen shown during mammogram AI analysis
class AnalyzingScreen extends StatefulWidget {
  final ScanCubit scanCubit;
  final bool fromCamera;
  final DoctorModel doctor;
  final Function(String patientId)? onPatientSaved;

  const AnalyzingScreen({
    super.key,
    required this.scanCubit,
    required this.fromCamera,
    required this.doctor,
    this.onPatientSaved,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    if (widget.fromCamera) {
      unawaited(widget.scanCubit.pickFromCamera());
    } else {
      unawaited(widget.scanCubit.pickFromGallery());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.scanCubit,
      child: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state.status == ScanStatus.resultReady) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  scanCubit: widget.scanCubit,
                  doctor: widget.doctor,
                  onPatientSaved: widget.onPatientSaved,
                ),
              ),
            );
          } else if (state.status == ScanStatus.error) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.negative,
              ),
            );
          } else if (state.status == ScanStatus.initial) {
            // User cancelled image picking
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  widget.scanCubit.reset();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
              title: Text(
                'Analyzing',
                style: AppTextStyles.h4,
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Analyzing animation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Analyzing Mammogram',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'AI is processing the image to detect potential abnormalities...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
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

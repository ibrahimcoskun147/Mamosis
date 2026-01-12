

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/doctor_model.dart';
import '../cubit/scan_cubit.dart';
import 'analyzing_screen.dart';

/// Bottom sheet for selecting image source (Camera/Gallery)
class ScanBottomSheet extends StatelessWidget {
  final DoctorModel doctor;
  final Function(String patientId)? onPatientSaved;

  const ScanBottomSheet({
    super.key,
    required this.doctor,
    this.onPatientSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Image Source',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 24),
          // Camera Option
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            subtitle: 'Take a new photo',
            onTap: () {
              Navigator.pop(context);
              _startScan(context, fromCamera: true);
            },
          ),
          const SizedBox(height: 12),
          // Gallery Option
          _OptionTile(
            icon: Icons.photo_library_outlined,
            title: 'Gallery',
            subtitle: 'Choose from your photos',
            onTap: () {
              Navigator.pop(context);
              _startScan(context, fromCamera: false);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _startScan(BuildContext context, {required bool fromCamera}) {
    final scanCubit = getIt<ScanCubit>();
    
    unawaited(Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          scanCubit: scanCubit,
          fromCamera: fromCamera,
          doctor: doctor,
          onPatientSaved: onPatientSaved,
        ),
      ),
    ));
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

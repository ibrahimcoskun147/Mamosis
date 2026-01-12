import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/patient_model.dart';

/// Patient detail screen showing all patient information
class PatientDetailScreen extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Patient Details',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Patient Name',
                    value: patient.fullName,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: AppStrings.patientIdentityNumber,
                    value: patient.patientId.isNotEmpty 
                        ? patient.patientId 
                        : '-',
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.medical_services_outlined,
                    label: AppStrings.patientStatus,
                    value: patient.status,
                    valueColor: patient.isPositive
                        ? AppColors.positive
                        : AppColors.negative,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: AppStrings.processDate,
                    value: patient.formattedDate,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: AppStrings.documentNumber,
                    value: patient.id.length >= 8 
                        ? patient.id.substring(0, 8) 
                        : patient.id,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Mammogram Image Section
            Text(
              AppStrings.patientMammogramImage,
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  if (patient.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        patient.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.white54,
                        size: 48,
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
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            ' ......... ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              overflow: TextOverflow.clip,
            ),
            maxLines: 1,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

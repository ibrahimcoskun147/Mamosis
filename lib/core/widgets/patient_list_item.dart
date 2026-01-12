import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Patient list item widget reused in Home and Patient List screens
class PatientListItem extends StatelessWidget {
  final String patientName;
  final String status;
  final String date;
  final VoidCallback? onDetailsTap;
  final bool showDivider;

  const PatientListItem({
    super.key,
    required this.patientName,
    required this.status,
    required this.date,
    this.onDetailsTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = status.toLowerCase() == 'positive';
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Patient Name
              Expanded(
                flex: 3,
                child: Text(
                  patientName,
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status
              Expanded(
                flex: 2,
                child: Text(
                  status,
                  style: isPositive
                      ? AppTextStyles.positiveStatus
                      : AppTextStyles.negativeStatus,
                ),
              ),
              // Date
              Expanded(
                flex: 2,
                child: Text(
                  date,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              // Details Button
              if (onDetailsTap != null)
                GestureDetector(
                  onTap: onDetailsTap,
                  child: Text(
                    'Details',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showDivider) 
          const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

/// Table header for patient list
class PatientListHeader extends StatelessWidget {
  const PatientListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Patient Name',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 50), // Space for Details button
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Statistic card widget for dashboard
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                ),
                Expanded(
                  child: Text(
                    ' ..................... ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                      overflow: TextOverflow.clip,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            count.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

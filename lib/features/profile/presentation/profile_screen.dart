

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/doctor_model.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/presentation/login_screen.dart';
import '../../paywall/presentation/paywall_screen.dart';

/// Profile screen with Pro badge
class ProfileScreen extends StatefulWidget {
  final DoctorModel? doctor;
  final Function(DoctorModel)? onDoctorUpdated;

  const ProfileScreen({
    super.key, 
    this.doctor,
    this.onDoctorUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DoctorModel? _doctor;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctor != oldWidget.doctor) {
      _doctor = widget.doctor;
    }
  }

  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallScreen(
        doctor: _doctor,
        onProUpgrade: (updatedDoctor) {
          setState(() {
            _doctor = updatedDoctor;
          });
          widget.onDoctorUpdated?.call(updatedDoctor);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = _doctor?.isPro ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Avatar with Pro badge
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: AppColors.accent,
                  ),
                ),
                if (isPro)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Name with Pro badge inline
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _doctor?.fullName ?? 'Doctor',
                  style: AppTextStyles.h3,
                ),
                if (isPro) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.positive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.positive,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _doctor?.organisation ?? 'Organisation',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 32),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.workspace_premium,
                    iconColor: AppColors.accent,
                    title: AppStrings.accountSettings,
                    badge: isPro ? 'Active' : null,
                    badgeColor: isPro ? AppColors.positive : null,
                    onTap: _showPaywall,
                  ),
                  const SizedBox(height: 12),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.warning,
                    title: AppStrings.notificationPreferences,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _MenuItem(
                    icon: Icons.help_outline,
                    iconColor: AppColors.positive,
                    title: AppStrings.helpSupport,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => _logout(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.logOut,
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authCubit = getIt<AuthCubit>();
    await authCubit.logout();
    
    if (context.mounted) {
      unawaited(Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      ));
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppTextStyles.labelLarge),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.caption.copyWith(
                    color: badgeColor ?? AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

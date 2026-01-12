import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/doctor_model.dart';

/// Paywall screen with Pro status check
class PaywallScreen extends StatefulWidget {
  final DoctorModel? doctor;
  final Function(DoctorModel)? onProUpgrade;

  const PaywallScreen({
    super.key,
    this.doctor,
    this.onProUpgrade,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _upgradeToPro() async {
    if (widget.doctor == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Update isPro in Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor!.id)
          .update({'isPro': true});
      
      // Notify parent
      final updatedDoctor = widget.doctor!.copyWith(isPro: true);
      widget.onProUpgrade?.call(updatedDoctor);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.paymentSuccessful),
            backgroundColor: AppColors.positive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upgrade failed: $e'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = widget.doctor?.isPro ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Icon - different for Pro users
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isPro ? AppColors.positive : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPro ? Icons.workspace_premium : Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title - different for Pro users
                  Text(
                    isPro ? 'You\'re a Pro!' : AppStrings.upgradePlan,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPro 
                        ? 'You already have access to all premium features' 
                        : AppStrings.unlockPotential,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Features
                  _FeatureItem(
                    icon: Icons.cloud_outlined,
                    title: 'Unlimited Archive Storage',
                    description: 'Securely store and retrieve historical scans without limits.',
                    isActive: isPro,
                  ),
                  const SizedBox(height: 20),
                  _FeatureItem(
                    icon: Icons.hd_outlined,
                    title: '4K High-Resolution Analysis',
                    description: 'Deep-dive into diagnostic details with ultra-clear rendering.',
                    isActive: isPro,
                  ),
                  const SizedBox(height: 20),
                  _FeatureItem(
                    icon: Icons.bolt_outlined,
                    title: 'Priority AI Processing',
                    description: 'Get results in seconds with dedicated server clusters.',
                    isActive: isPro,
                  ),
                  const SizedBox(height: 32),
                  // Show different content based on Pro status
                  if (isPro) ...[
                    // Pro user - show active status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.positive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.positive),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppColors.positive,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRO ACTIVE',
                                  style: AppTextStyles.caption.copyWith(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.positive,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All premium features are unlocked',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Close button for Pro users
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ] else ...[
                    // Non-Pro user - show pricing
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.proMonthly,
                                  style: AppTextStyles.caption.copyWith(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.price,
                                  style: AppTextStyles.h3,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.positive.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              AppStrings.save20,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.positive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // CTA Button
                    PrimaryButton(
                      text: AppStrings.startProTrial,
                      isLoading: _isLoading,
                      onPressed: _upgradeToPro,
                    ),
                    const SizedBox(height: 16),
                    // Terms
                    Text.rich(
                      TextSpan(
                        text: '7-day free trial, then \$19.99/mo. Cancel anytime in Settings. By continuing, you agree to our ',
                        style: AppTextStyles.caption,
                        children: [
                          TextSpan(
                            text: 'Terms',
                            style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isActive;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon, 
          size: 24, 
          color: isActive ? AppColors.positive : AppColors.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.positive,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

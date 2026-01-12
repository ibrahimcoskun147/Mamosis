import 'package:flutter/material.dart';
import '../../../data/models/doctor_model.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/patient_list/presentation/patient_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Main navigation with bottom nav bar
class MainNavigation extends StatefulWidget {
  final String? phoneNumber;
  final DoctorModel? doctor;

  const MainNavigation({
    super.key,
    this.phoneNumber,
    this.doctor,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late DoctorModel? _doctor;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
  }

  /// Update doctor after patient is added
  void updateDoctor(DoctorModel newDoctor) {
    setState(() {
      _doctor = newDoctor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        phoneNumber: widget.phoneNumber,
        doctor: _doctor,
        onDoctorUpdated: updateDoctor,
      ),
      PatientListScreen(doctor: _doctor),
      ProfileScreen(
        doctor: _doctor,
        onDoctorUpdated: updateDoctor,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: AppStrings.home,
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: AppStrings.lists,
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: AppStrings.profile,
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

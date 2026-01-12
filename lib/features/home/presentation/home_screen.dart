import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/patient_list_item.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/doctor_model.dart';
import '../../patient_detail/presentation/patient_detail_screen.dart';
import '../../scan_process/presentation/scan_bottom_sheet.dart';
import '../cubit/home_cubit.dart';

/// Home dashboard screen
class HomeScreen extends StatefulWidget {
  final String? phoneNumber;
  final DoctorModel? doctor;
  final Function(DoctorModel)? onDoctorUpdated;

  const HomeScreen({
    super.key,
    this.phoneNumber,
    this.doctor,
    this.onDoctorUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = getIt<HomeCubit>();
    _loadData();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update cubit when doctor changes (e.g., after Pro upgrade)
    if (widget.doctor != oldWidget.doctor && widget.doctor != null) {
      _homeCubit.setDoctor(widget.doctor!);
    }
  }

  void _loadData() {
    _homeCubit.loadDashboard(
      phoneNumber: widget.phoneNumber,
      doctor: widget.doctor,
    );
  }

  void _showScanBottomSheet() {
    final doctor = _homeCubit.state.doctor;
    if (doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor info not loaded')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanBottomSheet(
        doctor: doctor,
        onPatientSaved: (newPatientId) {
          // Update doctor with new patient ID
          final updatedDoctor = doctor.copyWith(
            patients: [...doctor.patients, newPatientId],
          );
          _homeCubit.updateDoctorPatients(updatedDoctor.patients);
          widget.onDoctorUpdated?.call(updatedDoctor);
          // Refresh dashboard
          _homeCubit.refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async => _homeCubit.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_outline,
                            size: 28,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.appName,
                            style: AppTextStyles.h3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Greeting with Pro badge
                      Row(
                        children: [
                          Text(
                            'Hello, ${state.doctor?.fullName ?? 'Doctor'}',
                            style: AppTextStyles.h3,
                          ),
                          if (state.doctor?.isPro == true) ...[
                            const SizedBox(width: 8),
                            Container(
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
                                borderRadius: BorderRadius.circular(8),
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
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organization: ${state.doctor?.organisation ?? 'Organisation'}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      // Statistics
                      StatCard(
                        icon: Icons.grid_view_rounded,
                        title: AppStrings.totalMammogram,
                        count: state.totalCount,
                      ),
                      StatCard(
                        icon: Icons.check_circle_outline,
                        title: AppStrings.positiveMammogram,
                        count: state.positiveCount,
                        iconColor: AppColors.primary,
                      ),
                      StatCard(
                        icon: Icons.cancel_outlined,
                        title: AppStrings.negativeMammogram,
                        count: state.negativeCount,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: 32),
                      // Recent List Title
                      Text(
                        AppStrings.recentlyAnalyzed,
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 16),
                      // Table Header
                      const PatientListHeader(),
                      const Divider(height: 1),
                      // Patient List
                      if (state.status == HomeStatus.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.recentPatients.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No patients yet',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...state.recentPatients.map(
                          (patient) => PatientListItem(
                            patientName: patient.fullName,
                            status: patient.status,
                            date: patient.formattedDate,
                            showDivider: patient != state.recentPatients.last,
                            onDetailsTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Start Scan Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.startScanTitle,
                              style: AppTextStyles.h4,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.startScanDesc,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              text: AppStrings.startScan,
                              onPressed: _showScanBottomSheet,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

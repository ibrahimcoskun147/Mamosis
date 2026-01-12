import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/patient_list_item.dart';
import '../../../data/models/doctor_model.dart';
import '../../patient_detail/presentation/patient_detail_screen.dart';
import '../cubit/patient_list_cubit.dart';

/// Patient list screen showing all patients for the logged-in doctor
class PatientListScreen extends StatefulWidget {
  final DoctorModel? doctor;

  const PatientListScreen({super.key, this.doctor});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late final PatientListCubit _patientListCubit;

  @override
  void initState() {
    super.initState();
    _patientListCubit = getIt<PatientListCubit>();
    _loadPatients();
  }

  void _loadPatients() {
    final patientIds = widget.doctor?.patients ?? [];
    _patientListCubit.loadPatients(patientIds);
  }

  @override
  void didUpdateWidget(PatientListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if doctor's patients changed
    if (widget.doctor?.patients != oldWidget.doctor?.patients) {
      _loadPatients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _patientListCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            AppStrings.mammogramList,
            style: AppTextStyles.h4,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PatientListCubit, PatientListState>(
          builder: (context, state) {
            // Show full loading only for initial load
            if (state.status == PatientListStatus.loading && state.patients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == PatientListStatus.error && state.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading patients',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPatients,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.patients.isEmpty) {
              return Center(
                child: Text(
                  'No patients yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    final patientIds = widget.doctor?.patients ?? [];
                    await _patientListCubit.refresh(patientIds);
                  },
                  child: Column(
                    children: [
                      // Header
                      Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Table Header
                            Padding(
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
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: state.patients.length,
                          itemBuilder: (context, index) {
                            final patient = state.patients[index];
                            return PatientListItem(
                              patientName: patient.fullName,
                              status: patient.status,
                              date: patient.formattedDate,
                              showDivider: index < state.patients.length - 1,
                              onDetailsTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PatientDetailScreen(
                                      patient: patient,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Pagination (UI only for now)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.surface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const IconButton(
                              onPressed: null,
                              icon: Icon(Icons.chevron_left),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('1', style: AppTextStyles.bodyMedium),
                            ),
                            const IconButton(
                              onPressed: null,
                              icon: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Loading overlay during refresh
                if (state.status == PatientListStatus.refreshing)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

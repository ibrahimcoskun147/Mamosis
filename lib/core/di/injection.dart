import 'package:get_it/get_it.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/patient_datasource.dart';
import '../../data/datasources/storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/patient_list/cubit/patient_list_cubit.dart';
import '../../features/scan_process/cubit/scan_cubit.dart';
import '../../features/scan_process/services/mammogram_analyzer.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Datasources
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasource());
  getIt.registerLazySingleton<PatientDatasource>(() => PatientDatasource());
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDatasource>()),
  );
  getIt.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(getIt<PatientDatasource>()),
  );
  
  // AI Service
  getIt.registerLazySingleton<MammogramAnalyzer>(() => MammogramAnalyzer());
  
  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      patientRepository: getIt<PatientRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<PatientListCubit>(
    () => PatientListCubit(getIt<PatientRepository>()),
  );
  getIt.registerFactory<ScanCubit>(
    () => ScanCubit(
      patientRepository: getIt<PatientRepository>(),
      authRepository: getIt<AuthRepository>(),
      storageService: getIt<StorageService>(),
      mammogramAnalyzer: getIt<MammogramAnalyzer>(),
    ),
  );
}

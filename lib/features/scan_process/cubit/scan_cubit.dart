import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/storage_service.dart';
import '../../../data/models/patient_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/patient_repository.dart';
import '../services/mammogram_analyzer.dart';

part 'scan_state.dart';

/// Scan Cubit for mammogram analysis workflow
class ScanCubit extends Cubit<ScanState> {
  final PatientRepository _patientRepository;
  final AuthRepository _authRepository;
  final StorageService _storageService;
  final MammogramAnalyzer _mammogramAnalyzer;
  final ImagePicker _imagePicker = ImagePicker();

  ScanCubit({
    required PatientRepository patientRepository,
    required AuthRepository authRepository,
    required StorageService storageService,
    required MammogramAnalyzer mammogramAnalyzer,
  })  : _patientRepository = patientRepository,
        _authRepository = authRepository,
        _storageService = storageService,
        _mammogramAnalyzer = mammogramAnalyzer,
        super(const ScanState());

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to capture image: $e',
      ));
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to pick image: $e',
      ));
    }
  }

  /// Analyze the selected image
  Future<void> _analyzeImage(File imageFile) async {
    emit(state.copyWith(
      status: ScanStatus.analyzing,
      selectedImage: imageFile,
    ));

    try {
      // Run AI analysis
      final result = await _mammogramAnalyzer.analyze(imageFile);

      emit(state.copyWith(
        status: ScanStatus.resultReady,
        analysisResult: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Analysis failed: $e',
      ));
    }
  }

  /// Save patient with mammogram result
  Future<void> savePatient({
    required String firstName,
    required String lastName,
    required String doctorId,
    String? patientId,
  }) async {
    if (state.selectedImage == null || state.analysisResult == null) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'No image or analysis result',
      ));
      return;
    }

    emit(state.copyWith(status: ScanStatus.saving));

    try {
      // Upload image to Firebase Storage
      final imageUrl = await _storageService.uploadMammogramImage(state.selectedImage!);

      // Create patient record
      final patient = PatientModel(
        id: '',
        patientId: patientId ?? '',
        firstName: firstName,
        lastName: lastName,
        status: state.analysisResult!.status,
        imageUrl: imageUrl,
        riskDescription: state.analysisResult!.riskDescription,
        createdAt: DateTime.now(),
      );

      // Save to Firestore and get the new patient with ID
      final savedPatient = await _patientRepository.addPatient(patient);

      // Add patient ID to doctor's patients array
      await _authRepository.addPatientToDoctor(doctorId, savedPatient.id);

      emit(state.copyWith(
        status: ScanStatus.saved,
        savedPatientId: savedPatient.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to save patient: $e',
      ));
    }
  }

  /// Reset scan state
  void reset() {
    emit(const ScanState());
  }
}

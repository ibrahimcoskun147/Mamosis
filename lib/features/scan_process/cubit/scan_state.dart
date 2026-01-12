part of 'scan_cubit.dart';

enum ScanStatus {
  initial,
  analyzing,
  resultReady,
  saving,
  saved,
  error,
}

class ScanState extends Equatable {
  final ScanStatus status;
  final File? selectedImage;
  final MammogramAnalysisResult? analysisResult;
  final String errorMessage;
  final String? savedPatientId;

  const ScanState({
    this.status = ScanStatus.initial,
    this.selectedImage,
    this.analysisResult,
    this.errorMessage = '',
    this.savedPatientId,
  });

  ScanState copyWith({
    ScanStatus? status,
    File? selectedImage,
    MammogramAnalysisResult? analysisResult,
    String? errorMessage,
    String? savedPatientId,
  }) {
    return ScanState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      analysisResult: analysisResult ?? this.analysisResult,
      errorMessage: errorMessage ?? this.errorMessage,
      savedPatientId: savedPatientId ?? this.savedPatientId,
    );
  }

  @override
  List<Object?> get props => [status, selectedImage, analysisResult, errorMessage, savedPatientId];
}

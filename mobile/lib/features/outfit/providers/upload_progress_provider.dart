import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadStep {
  idle,
  validating,
  gettingPresignedUrl,
  uploading,
  verifying,
  creatingSession,
  complete,
  error,
}

class UploadProgress {
  final UploadStep step;
  final double progress; // 0.0 to 1.0
  final String? message;
  final String? errorMessage;

  const UploadProgress({
    required this.step,
    this.progress = 0.0,
    this.message,
    this.errorMessage,
  });

  UploadProgress copyWith({
    UploadStep? step,
    double? progress,
    String? message,
    String? errorMessage,
  }) {
    return UploadProgress(
      step: step ?? this.step,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get stepDescription {
    switch (step) {
      case UploadStep.idle:
        return 'Ready to upload';
      case UploadStep.validating:
        return 'Validating file...';
      case UploadStep.gettingPresignedUrl:
        return 'Preparing upload...';
      case UploadStep.uploading:
        return 'Uploading image...';
      case UploadStep.verifying:
        return 'Verifying upload...';
      case UploadStep.creatingSession:
        return 'Creating outfit session...';
      case UploadStep.complete:
        return 'Complete!';
      case UploadStep.error:
        return 'Upload failed';
    }
  }

  int get progressPercentage => (progress * 100).round();
}

class UploadProgressNotifier extends StateNotifier<UploadProgress> {
  UploadProgressNotifier()
      : super(const UploadProgress(step: UploadStep.idle));

  void reset() {
    state = const UploadProgress(step: UploadStep.idle);
  }

  void setValidating() {
    state = state.copyWith(
      step: UploadStep.validating,
      progress: 0.1,
      message: 'Checking file...',
    );
  }

  void setGettingPresignedUrl() {
    state = state.copyWith(
      step: UploadStep.gettingPresignedUrl,
      progress: 0.2,
      message: 'Preparing secure upload...',
    );
  }

  void setUploading(double progress) {
    state = state.copyWith(
      step: UploadStep.uploading,
      progress: 0.2 + (progress * 0.5), // 20% to 70%
      message: 'Uploading ${(progress * 100).round()}%...',
    );
  }

  void setVerifying() {
    state = state.copyWith(
      step: UploadStep.verifying,
      progress: 0.75,
      message: 'Verifying upload...',
    );
  }

  void setCreatingSession() {
    state = state.copyWith(
      step: UploadStep.creatingSession,
      progress: 0.85,
      message: 'Analyzing your outfit...',
    );
  }

  void setComplete() {
    state = state.copyWith(
      step: UploadStep.complete,
      progress: 1.0,
      message: 'Success!',
    );
  }

  void setError(String error) {
    state = state.copyWith(
      step: UploadStep.error,
      errorMessage: error,
      message: 'Upload failed',
    );
  }
}

final uploadProgressProvider =
    StateNotifierProvider<UploadProgressNotifier, UploadProgress>((ref) {
  return UploadProgressNotifier();
});

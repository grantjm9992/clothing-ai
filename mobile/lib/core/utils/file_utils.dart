import 'dart:io';
import 'package:path/path.dart' as path;
import '../config/app_config.dart';

class FileUtils {
  /// Get MIME type from file extension
  static String getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.heif':
        return 'image/heif';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Validate file extension
  static bool isValidExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return AppConfig.allowedExtensions.contains(extension);
  }

  /// Validate MIME type
  static bool isValidMimeType(String mimeType) {
    return AppConfig.allowedMimeTypes.contains(mimeType);
  }

  /// Get file size
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Validate file size
  static bool isValidFileSize(int fileSize) {
    return fileSize > 0 && fileSize <= AppConfig.maxFileSize;
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Validate image file
  static Future<FileValidationResult> validateImageFile(File file) async {
    // Check if file exists
    if (!await file.exists()) {
      return FileValidationResult(
        isValid: false,
        error: 'File does not exist',
      );
    }

    final filePath = file.path;

    // Validate extension
    if (!isValidExtension(filePath)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid file type. Allowed: ${AppConfig.allowedExtensions.join(", ")}',
      );
    }

    // Get and validate file size
    final fileSize = await getFileSize(file);
    if (!isValidFileSize(fileSize)) {
      return FileValidationResult(
        isValid: false,
        error: 'File too large. Maximum size: ${formatFileSize(AppConfig.maxFileSize)}',
        fileSize: fileSize,
      );
    }

    // Get MIME type
    final mimeType = getMimeType(filePath);
    if (!isValidMimeType(mimeType)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid MIME type: $mimeType',
        fileSize: fileSize,
      );
    }

    return FileValidationResult(
      isValid: true,
      fileSize: fileSize,
      mimeType: mimeType,
    );
  }
}

class FileValidationResult {
  final bool isValid;
  final String? error;
  final int? fileSize;
  final String? mimeType;

  FileValidationResult({
    required this.isValid,
    this.error,
    this.fileSize,
    this.mimeType,
  });
}

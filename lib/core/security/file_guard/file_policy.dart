import 'package:fluttea/core/constants/security/security_consts.dart';

final class FileValidationResult {
  const new valid() : isValid = true, reason = null;

  const new invalid(this.reason) : isValid = false;

  final bool isValid;
  final String? reason;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid($reason)';
}

final class FilePolicy {
  const new({
    required this.allowedExtensions,
    required this.allowedMimeTypes,
    this.maxFileSizeBytes = SecurityConsts.defaultMaxFileSizeBytes,
  });

  factory imageOnly({int maxBytes = 5 * 1024 * 1024}) {
    return FilePolicy(
      allowedExtensions: const {'jpg', 'jpeg', 'png', 'webp', 'gif'},
      allowedMimeTypes: const {'image/jpeg', 'image/png', 'image/webp', 'image/gif'},
      maxFileSizeBytes: maxBytes,
    );
  }

  factory document({int maxBytes = SecurityConsts.defaultMaxFileSizeBytes}) {
    return FilePolicy(
      allowedExtensions: const {'pdf', 'csv', 'txt', 'docx', 'xlsx'},
      allowedMimeTypes: const {
        'application/pdf',
        'text/csv',
        'text/plain',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      },
      maxFileSizeBytes: maxBytes,
    );
  }

  final Set<String> allowedExtensions;
  final Set<String> allowedMimeTypes;
  final int maxFileSizeBytes;

  FileValidationResult validate({
    required String fileName,
    required int byteLength,
    String? mimeType,
  }) {
    if (byteLength <= 0) {
      return const FileValidationResult.invalid('File is empty');
    }
    if (byteLength > maxFileSizeBytes) {
      return FileValidationResult.invalid(
        'File size ($byteLength bytes) exceeds maximum allowed ($maxFileSizeBytes bytes)',
      );
    }

    final ext = _extractExtension(fileName);
    if (ext.isEmpty || !allowedExtensions.contains(ext.toLowerCase())) {
      return FileValidationResult.invalid(
        'Extension "$ext" is not allowed. Allowed: ${allowedExtensions.join(', ')}',
      );
    }

    if (mimeType != null && mimeType.isNotEmpty) {
      if (!allowedMimeTypes.contains(mimeType.toLowerCase())) {
        return FileValidationResult.invalid(
          'MIME type "$mimeType" is not allowed. Allowed: ${allowedMimeTypes.join(', ')}',
        );
      }
    }

    return const FileValidationResult.valid();
  }

  static String _extractExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}

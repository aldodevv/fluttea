enum DetectedFileType {
  jpeg('jpg', 'image/jpeg'),
  png('png', 'image/png'),
  gif('gif', 'image/gif'),
  webp('webp', 'image/webp'),
  pdf('pdf', 'application/pdf'),
  zip('zip', 'application/zip'),
  unknown('', 'application/octet-stream');

  new(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

final class MagicBytesInspector {
  const new();

  DetectedFileType detect(List<int> bytes) {
    if (bytes.length < 4) return DetectedFileType.unknown;

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return DetectedFileType.jpeg;
    }

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return DetectedFileType.png;
    }

    // GIF: GIF8 (47 49 46 38)
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
      return DetectedFileType.gif;
    }

    // PDF: %PDF (25 50 44 46)
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
      return DetectedFileType.pdf;
    }

    // WebP: RIFF....WEBP (52 49 46 46 .... 57 45 42 50)
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return DetectedFileType.webp;
    }

    // ZIP / PK: 50 4B 03 04 or 50 4B 05 06
    if (bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        ((bytes[2] == 0x03 && bytes[3] == 0x04) || (bytes[2] == 0x05 && bytes[3] == 0x06))) {
      return DetectedFileType.zip;
    }

    return DetectedFileType.unknown;
  }

  bool verifyExtension({required List<int> bytes, required String declaredExtension}) {
    final cleanExt = declaredExtension.replaceAll('.', '').toLowerCase();
    final detected = detect(bytes);

    switch (detected) {
      case DetectedFileType.jpeg:
        return cleanExt == 'jpg' || cleanExt == 'jpeg';
      case DetectedFileType.png:
        return cleanExt == 'png';
      case DetectedFileType.gif:
        return cleanExt == 'gif';
      case DetectedFileType.webp:
        return cleanExt == 'webp';
      case DetectedFileType.pdf:
        return cleanExt == 'pdf';
      case DetectedFileType.zip:
        return const {'zip', 'docx', 'xlsx', 'apk', 'jar'}.contains(cleanExt);
      case DetectedFileType.unknown:
        return false;
    }
  }
}

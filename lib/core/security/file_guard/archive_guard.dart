import 'package:fluttea/core/constants/security/security_consts.dart';

final class ArchiveEntryDescriptor {
  const new({required this.name, required this.compressedSize, required this.uncompressedSize});

  final String name;
  final int compressedSize;
  final int uncompressedSize;
}

final class ArchiveGuardResult {
  const new valid() : isValid = true, reason = null;

  const new invalid(this.reason) : isValid = false;

  final bool isValid;
  final String? reason;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid($reason)';
}

final class ArchiveGuard {
  const new({
    this.maxEntries = SecurityConsts.maxArchiveEntries,
    this.maxTotalExpansionBytes = SecurityConsts.maxArchiveExpansionSizeBytes,
    this.maxCompressionRatio = SecurityConsts.maxArchiveCompressionRatio,
  });

  final int maxEntries;
  final int maxTotalExpansionBytes;
  final double maxCompressionRatio;

  bool isPathSafe(String entryPath) {
    if (entryPath.contains('\x00')) return false;

    // Check directory traversal sequences
    if (entryPath.contains('../') || entryPath.contains(r'..\')) return false;
    if (entryPath == '..' || entryPath.endsWith('/..') || entryPath.endsWith(r'\..')) {
      return false;
    }

    // Check absolute path prefixes
    if (entryPath.startsWith('/') || entryPath.startsWith(r'\')) return false;
    if (entryPath.length >= 2 &&
        entryPath[1] == ':' &&
        entryPath[0].toUpperCase().codeUnitAt(0) >= 65 &&
        entryPath[0].toUpperCase().codeUnitAt(0) <= 90) {
      return false;
    }

    return true;
  }

  ArchiveGuardResult inspectEntries(
    List<ArchiveEntryDescriptor> entries, {
    int? totalArchiveCompressedBytes,
  }) {
    if (entries.length > maxEntries) {
      return ArchiveGuardResult.invalid(
        'Archive entries count (${entries.length}) exceeds maximum limit ($maxEntries)',
      );
    }

    var totalUncompressed = 0;
    var totalCompressed = 0;

    for (final entry in entries) {
      if (!isPathSafe(entry.name)) {
        return ArchiveGuardResult.invalid(
          'Potential Zip Slip path traversal detected in entry: "${entry.name}"',
        );
      }

      if (entry.uncompressedSize < 0 || entry.compressedSize < 0) {
        return const ArchiveGuardResult.invalid(
          'Negative entry sizes detected in archive metadata',
        );
      }

      totalUncompressed += entry.uncompressedSize;
      totalCompressed += entry.compressedSize;

      if (totalUncompressed > maxTotalExpansionBytes) {
        return ArchiveGuardResult.invalid(
          'Total uncompressed size ($totalUncompressed bytes) exceeds maximum allowed ($maxTotalExpansionBytes bytes)',
        );
      }
    }

    final effectiveCompressed = totalArchiveCompressedBytes ?? totalCompressed;
    if (effectiveCompressed > 0) {
      final ratio = totalUncompressed / effectiveCompressed;
      if (ratio > maxCompressionRatio) {
        return ArchiveGuardResult.invalid(
          'Compression ratio (${ratio.toStringAsFixed(1)}:1) exceeds threshold (${maxCompressionRatio.toInt()}:1)',
        );
      }
    }

    return const ArchiveGuardResult.valid();
  }
}

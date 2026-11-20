import 'package:fluttea/core/security/file_guard/archive_guard.dart';
import 'package:fluttea/core/security/file_guard/file_hasher.dart';
import 'package:fluttea/core/security/file_guard/file_policy.dart';
import 'package:fluttea/core/security/file_guard/magic_bytes.dart';
import 'package:fluttea/core/security/file_guard/scan_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilePolicy', () {
    final imagePolicy = FilePolicy.imageOnly(maxBytes: 1024 * 1024); // 1 MB

    test('validates allowed image format and size', () {
      final res = imagePolicy.validate(
        fileName: 'avatar.png',
        byteLength: 500000,
        mimeType: 'image/png',
      );
      expect(res.isValid, isTrue);
      expect(res.reason, isNull);
    });

    test('rejects empty files', () {
      final res = imagePolicy.validate(fileName: 'avatar.png', byteLength: 0);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('empty'));
    });

    test('rejects oversized files', () {
      final res = imagePolicy.validate(fileName: 'huge.jpg', byteLength: 2 * 1024 * 1024);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('exceeds maximum'));
    });

    test('rejects disallowed extension', () {
      final res = imagePolicy.validate(fileName: 'malware.sh', byteLength: 100);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('not allowed'));
    });

    test('rejects mismatched MIME type', () {
      final res = imagePolicy.validate(
        fileName: 'photo.jpg',
        byteLength: 1000,
        mimeType: 'application/x-executable',
      );
      expect(res.isValid, isFalse);
    });
  });

  group('MagicBytesInspector', () {
    const inspector = MagicBytesInspector();

    test('detects JPEG header', () {
      final bytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10];
      expect(inspector.detect(bytes), DetectedFileType.jpeg);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'jpg'), isTrue);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'jpeg'), isTrue);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'png'), isFalse);
    });

    test('detects PNG header', () {
      final bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00];
      expect(inspector.detect(bytes), DetectedFileType.png);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'png'), isTrue);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'jpg'), isFalse);
    });

    test('detects PDF header', () {
      final bytes = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x35];
      expect(inspector.detect(bytes), DetectedFileType.pdf);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'pdf'), isTrue);
    });

    test('detects ZIP header', () {
      final bytes = [0x50, 0x4B, 0x03, 0x04, 0x14, 0x00];
      expect(inspector.detect(bytes), DetectedFileType.zip);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'zip'), isTrue);
      expect(inspector.verifyExtension(bytes: bytes, declaredExtension: 'docx'), isTrue);
    });

    test('rejects disguised malicious binary', () {
      // ELF header disguised as avatar.png
      final elfBytes = [0x7F, 0x45, 0x4C, 0x46, 0x02, 0x01];
      expect(inspector.detect(elfBytes), DetectedFileType.unknown);
      expect(inspector.verifyExtension(bytes: elfBytes, declaredExtension: 'png'), isFalse);
    });
  });

  group('ArchiveGuard', () {
    const guard = ArchiveGuard(
      maxEntries: 10,
      maxTotalExpansionBytes: 100000,
      maxCompressionRatio: 10,
    );

    test('allows safe archive entries', () {
      final entries = [
        const ArchiveEntryDescriptor(
          name: 'docs/readme.txt',
          compressedSize: 100,
          uncompressedSize: 500,
        ),
        const ArchiveEntryDescriptor(
          name: 'images/logo.png',
          compressedSize: 200,
          uncompressedSize: 800,
        ),
      ];
      final res = guard.inspectEntries(entries, totalArchiveCompressedBytes: 300);
      expect(res.isValid, isTrue);
    });

    test('detects and blocks Zip Slip path traversal', () {
      final entries = [
        const ArchiveEntryDescriptor(
          name: '../../etc/passwd',
          compressedSize: 50,
          uncompressedSize: 100,
        ),
      ];
      final res = guard.inspectEntries(entries);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('Zip Slip'));
    });

    test('blocks absolute path traversal', () {
      expect(guard.isPathSafe('/usr/local/bin/run'), isFalse);
      expect(guard.isPathSafe(r'C:\Windows\System32\cmd.exe'), isFalse);
      expect(guard.isPathSafe('valid/path/file.txt'), isTrue);
    });

    test('detects zip bomb exceeding expansion size', () {
      final entries = [
        const ArchiveEntryDescriptor(
          name: 'bomb.txt',
          compressedSize: 100,
          uncompressedSize: 500000,
        ),
      ];
      final res = guard.inspectEntries(entries);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('exceeds maximum allowed'));
    });

    test('detects compression ratio threshold violation', () {
      final entries = [
        const ArchiveEntryDescriptor(
          name: 'nested.txt',
          compressedSize: 10,
          uncompressedSize: 5000,
        ),
      ];
      // 5000 / 10 = 500:1 ratio > 10.0
      final res = guard.inspectEntries(entries, totalArchiveCompressedBytes: 10);
      expect(res.isValid, isFalse);
      expect(res.reason, contains('Compression ratio'));
    });
  });

  group('FileHasher & MalwareScanClient', () {
    const hasher = FileHasher();

    test('hashBytes computes expected SHA-256 hex', () {
      final hash = hasher.hashBytes([1, 2, 3]);
      expect(hash.length, 64);
      expect(hasher.verifyHash([1, 2, 3], hash), isTrue);
      expect(hasher.verifyHash([1, 2, 4], hash), isFalse);
    });

    test('MockMalwareScanClient detects known threat hashes', () async {
      const knownHash = 'eicar_known_hash_hex';
      const client = MockMalwareScanClient(knownMalwareHashes: {knownHash});

      final clean = await client.scanFileHash('clean_hash_123');
      expect(clean.isClean, isTrue);

      final infected = await client.scanFileHash(knownHash);
      expect(infected.isClean, isFalse);
      expect(infected.threatName, isNotNull);
    });
  });
}

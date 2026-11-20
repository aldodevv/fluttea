import 'dart:io';

import 'package:crypto/crypto.dart';

final class FileHasher {
  const new();

  String hashBytes(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> hashFile(File file) async {
    final output = await sha256.bind(file.openRead()).first;
    return output.toString();
  }

  bool verifyHash(List<int> bytes, String expectedHex) {
    final actual = hashBytes(bytes);
    return actual.toLowerCase() == expectedHex.toLowerCase();
  }
}

abstract final class SecurityConsts {
  static const int aesGcmTagLength = 16;
  static const int nonceLength = 12;
  static const int saltLength = 16;
  static const int keyLength256Bits = 32;
  static const int pbkdf2Iterations = 100000;
  static const int argon2MemorySizeInKib = 19456;
  static const int argon2Iterations = 3;
  static const int argon2Parallelism = 2;
  static const int argon2HashLength = 32;
  static const int defaultEnvelopeVersion = 1;

  static const int maxFailedPinAttempts = 5;
  static const Duration sessionTimeoutDuration = Duration(minutes: 15);
  static const Duration backgroundLockDuration = Duration(minutes: 5);
  static const Duration defaultClipboardClearDelay = Duration(seconds: 30);

  // File guard thresholds
  static const int defaultMaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxArchiveEntries = 1000;
  static const int maxArchiveExpansionSizeBytes = 50 * 1024 * 1024; // 50 MB
  static const double maxArchiveCompressionRatio = 100;
}

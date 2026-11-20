import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/core/logging/app_log.dart';
import 'package:fluttea/core/storage/cache/memory_cache.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:fluttea/core/storage/secure/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

/// Di-override di bootstrap dengan env flavor aktif.
final appEnvProvider = Provider<AppEnv>(
  (ref) => throw UnimplementedError('appEnvProvider harus di-override di bootstrap'),
);

/// Provider logger Talker untuk DevTools dan debugging.
final talkerProvider = Provider<Talker>((ref) => AppLog.talker);

/// Provider Secure Storage untuk kredensial sensitif.
final secureStorageProvider = Provider<SecureStorage>((ref) => const SecureStorage());

/// Provider Preferences Storage untuk pengaturan non-sensitif.
final preferencesStorageProvider = Provider<PreferencesStorage>((ref) => PreferencesStorage());

/// Provider Memory Cache in-memory dengan TTL.
final memoryCacheProvider = Provider<MemoryCache>((ref) => MemoryCache());

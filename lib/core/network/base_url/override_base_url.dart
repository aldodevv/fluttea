import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/storage/storage_keys.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';

class OverrideBaseUrlResolver implements BaseUrlResolver {
  const new(this.storage, {this.allowOverride = true, this.enforceHttps = false});

  final PreferencesStorage storage;
  final bool allowOverride;
  final bool enforceHttps;

  @override
  Future<Uri> resolve({RequestOptions? options}) async {
    if (!allowOverride) {
      throw const FormatException('Base URL override is disabled in this environment.');
    }

    final raw = await storage.getString(StorageKeys.baseUrlOverride);
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('No override URL configured.');
    }

    final uri = Uri.parse(raw.trim());
    if (enforceHttps && uri.scheme != 'https') {
      throw const FormatException('Override URL must use HTTPS.');
    }

    return uri;
  }
}

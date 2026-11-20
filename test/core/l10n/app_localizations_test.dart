import 'dart:convert';
import 'dart:io';

import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/app/locale_codes.dart';
import 'package:fluttea/core/constants/asset_paths.dart';
import 'package:fluttea/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Set<String> _flattenKeys(Map<String, dynamic> map, [String prefix = '']) {
  final keys = <String>{};
  for (final entry in map.entries) {
    final fullKey = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    if (entry.value is Map<String, dynamic>) {
      keys.addAll(_flattenKeys(entry.value as Map<String, dynamic>, fullKey));
    } else {
      keys.add(fullKey);
    }
  }
  return keys;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations', () {
    test('id.json and en.json have identical keys', () {
      final idMap = jsonDecode(
        File(AssetPaths.l10n(LocaleCodes.id)).readAsStringSync(),
      ) as Map<String, dynamic>;
      final enMap = jsonDecode(
        File(AssetPaths.l10n(LocaleCodes.en)).readAsStringSync(),
      ) as Map<String, dynamic>;

      final idKeys = _flattenKeys(idMap);
      final enKeys = _flattenKeys(enMap);

      expect(idKeys.difference(enKeys), isEmpty, reason: 'Keys missing in en.json');
      expect(enKeys.difference(idKeys), isEmpty, reason: 'Keys missing in id.json');
    });

    test('loads id and en JSON assets and interpolates parameters', () async {
      final idL10n = await AppLocalizations.load(const Locale(LocaleCodes.id));
      final enL10n = await AppLocalizations.load(const Locale(LocaleCodes.en));

      expect(idL10n.authWelcomeTitle, 'Selamat Datang');
      expect(enL10n.authWelcomeTitle, 'Welcome');
      expect(idL10n.authWelcomeSubtitle(AppInfo.name), 'Masuk untuk melanjutkan ke Fluttea');
      expect(enL10n.authWelcomeSubtitle(AppInfo.name), 'Sign in to continue to Fluttea');
    });
  });
}

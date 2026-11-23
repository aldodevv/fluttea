import 'dart:convert';
import 'dart:io';

import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/app/locale_codes.dart';
import 'package:fluttea/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations', () {
    test('app_id.arb and app_en.arb have identical translation keys', () {
      final idMap = jsonDecode(
        File('lib/core/l10n/arb/app_id.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final enMap = jsonDecode(
        File('lib/core/l10n/arb/app_en.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

      final idKeys = idMap.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();

      expect(idKeys.difference(enKeys), isEmpty, reason: 'Keys missing in app_en.arb');
      expect(enKeys.difference(idKeys), isEmpty, reason: 'Keys missing in app_id.arb');
    });

    test('supports configured locales', () {
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode),
        containsAll([LocaleCodes.id, LocaleCodes.en]),
      );
      expect(AppLocalizations.delegate.isSupported(const Locale(LocaleCodes.id)), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale(LocaleCodes.en)), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('xx')), isFalse);
    });

    test('loads id and en localizations and interpolates parameters correctly', () async {
      final idL10n = await AppLocalizations.delegate.load(const Locale(LocaleCodes.id));
      final enL10n = await AppLocalizations.delegate.load(const Locale(LocaleCodes.en));

      expect(idL10n.authWelcomeTitle, 'Selamat Datang');
      expect(enL10n.authWelcomeTitle, 'Welcome');
      expect(idL10n.authWelcomeSubtitle(AppInfo.name), 'Masuk untuk melanjutkan ke Fluttea');
      expect(enL10n.authWelcomeSubtitle(AppInfo.name), 'Sign in to continue to Fluttea');
      expect(idL10n.homeGreeting('DevUser'), 'Halo, DevUser!');
      expect(enL10n.homeGreeting('DevUser'), 'Hello, DevUser!');
      expect(
        idL10n.settingsDeveloperSubtitle(AppFlavor.dev.name),
        'Fitur pengujian dan utilitas internal (dev)',
      );
      expect(
        enL10n.settingsDeveloperSubtitle(AppFlavor.dev.name),
        'Testing features and internal utilities (dev)',
      );
    });
  });
}

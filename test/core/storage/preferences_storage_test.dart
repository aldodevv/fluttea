import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync;

void main() {
  group('PreferencesStorage', () {
    late MockSharedPreferencesAsync mockPrefs;
    late PreferencesStorage preferencesStorage;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      preferencesStorage = PreferencesStorage(preferences: mockPrefs);
    });

    test('getString and setString', () async {
      when(() => mockPrefs.getString('theme')).thenAnswer((_) async => 'dark');
      when(() => mockPrefs.setString('theme', 'dark')).thenAnswer((_) async {});

      await preferencesStorage.setString('theme', 'dark');
      final value = await preferencesStorage.getString('theme');

      expect(value, equals('dark'));
      verify(() => mockPrefs.setString('theme', 'dark')).called(1);
      verify(() => mockPrefs.getString('theme')).called(1);
    });

    test('getInt and setInt', () async {
      when(() => mockPrefs.getInt('counter')).thenAnswer((_) async => 42);
      when(() => mockPrefs.setInt('counter', 42)).thenAnswer((_) async {});

      await preferencesStorage.setInt('counter', 42);
      final value = await preferencesStorage.getInt('counter');

      expect(value, equals(42));
      verify(() => mockPrefs.setInt('counter', 42)).called(1);
    });

    test('getBool and setBool', () async {
      when(() => mockPrefs.getBool('onboarding')).thenAnswer((_) async => true);
      when(() => mockPrefs.setBool('onboarding', true)).thenAnswer((_) async {});

      await preferencesStorage.setBool('onboarding', true);
      final value = await preferencesStorage.getBool('onboarding');

      expect(value, isTrue);
      verify(() => mockPrefs.setBool('onboarding', true)).called(1);
    });

    test('getDouble and setDouble', () async {
      when(() => mockPrefs.getDouble('scale')).thenAnswer((_) async => 1.5);
      when(() => mockPrefs.setDouble('scale', 1.5)).thenAnswer((_) async {});

      await preferencesStorage.setDouble('scale', 1.5);
      final value = await preferencesStorage.getDouble('scale');

      expect(value, equals(1.5));
      verify(() => mockPrefs.setDouble('scale', 1.5)).called(1);
    });

    test('getStringList and setStringList', () async {
      when(() => mockPrefs.getStringList('tags')).thenAnswer((_) async => ['dart', 'flutter']);
      when(() => mockPrefs.setStringList('tags', ['dart', 'flutter'])).thenAnswer((_) async {});

      await preferencesStorage.setStringList('tags', ['dart', 'flutter']);
      final value = await preferencesStorage.getStringList('tags');

      expect(value, equals(['dart', 'flutter']));
      verify(() => mockPrefs.setStringList('tags', ['dart', 'flutter'])).called(1);
    });

    test('remove and clear', () async {
      when(() => mockPrefs.remove('key')).thenAnswer((_) async {});
      when(() => mockPrefs.clear()).thenAnswer((_) async {});

      await preferencesStorage.remove('key');
      await preferencesStorage.clear();

      verify(() => mockPrefs.remove('key')).called(1);
      verify(() => mockPrefs.clear()).called(1);
    });
  });
}

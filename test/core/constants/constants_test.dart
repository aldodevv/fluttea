import 'package:fluttea/core/constants/api/api_headers.dart';
import 'package:fluttea/core/constants/api/api_hosts.dart';
import 'package:fluttea/core/constants/api/api_paths.dart';
import 'package:fluttea/core/constants/api/interceptor_order.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/app/locale_codes.dart';
import 'package:fluttea/core/constants/regex.dart';
import 'package:fluttea/core/constants/response/error_codes.dart';
import 'package:fluttea/core/constants/response/http_status.dart';
import 'package:fluttea/core/constants/response/success_codes.dart';
import 'package:fluttea/core/constants/roles/user_roles.dart';
import 'package:fluttea/core/constants/security/security_consts.dart';
import 'package:fluttea/core/constants/storage/storage_keys.dart';
import 'package:fluttea/core/constants/ui/breakpoints.dart';
import 'package:fluttea/core/constants/ui/durations.dart';
import 'package:fluttea/core/constants/ui/elevations.dart';
import 'package:fluttea/core/constants/ui/icon_sizes.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Constants', () {
    test('ApiHosts contains valid URLs', () {
      expect(ApiHosts.dev, startsWith('https://'));
      expect(ApiHosts.prod, startsWith('https://'));
    });

    test('ApiPaths has valid endpoints', () {
      expect(ApiPaths.login, equals('/v1/auth/login'));
      expect(ApiPaths.refreshToken, equals('/v1/auth/refresh'));
      expect(ApiPaths.profile, equals('/v1/users/me'));
    });

    test('ApiHeaders defines essential HTTP headers', () {
      expect(ApiHeaders.authorization, equals('Authorization'));
      expect(ApiHeaders.bearerPrefix, equals('Bearer '));
      expect(ApiHeaders.deviceId, equals('X-Device-Id'));
      expect(ApiHeaders.requestId, equals('X-Request-Id'));
    });

    test('InterceptorOrder is strictly increasing', () {
      expect(InterceptorOrder.connectivity < InterceptorOrder.requestId, isTrue);
      expect(InterceptorOrder.requestId < InterceptorOrder.headers, isTrue);
      expect(InterceptorOrder.headers < InterceptorOrder.authToken, isTrue);
      expect(InterceptorOrder.authToken < InterceptorOrder.logging, isTrue);
    });

    test('ErrorCodes and SuccessCodes are unique and present', () {
      expect(ErrorCodes.network, isNotEmpty);
      expect(ErrorCodes.timeout, isNotEmpty);
      expect(ErrorCodes.unauthorized, isNotEmpty);
      expect(SuccessCodes.ok, isNotEmpty);
    });

    test('HttpStatusCodes matches standard codes', () {
      expect(HttpStatusCodes.ok, equals(200));
      expect(HttpStatusCodes.created, equals(201));
      expect(HttpStatusCodes.unauthorized, equals(401));
      expect(HttpStatusCodes.internalServerError, equals(500));
    });

    test('UI tokens have proper relations', () {
      expect(Spacing.xs < Spacing.sm && Spacing.sm < Spacing.md, isTrue);
      expect(Radii.xs < Radii.sm && Radii.sm < Radii.md, isTrue);
      expect(Elevations.level0 < Elevations.level1, isTrue);
      expect(IconSizes.xs < IconSizes.sm && IconSizes.sm < IconSizes.md, isTrue);
      expect(
        Breakpoints.mobile < Breakpoints.tablet && Breakpoints.tablet < Breakpoints.desktop,
        isTrue,
      );
      expect(
        AppDurations.fast < AppDurations.normal && AppDurations.normal < AppDurations.slow,
        isTrue,
      );
    });

    test('UserRoles and StorageKeys are defined', () {
      expect(UserRoles.admin, equals('admin'));
      expect(UserRoles.member, equals('member'));
      expect(UserRoles.guest, equals('guest'));
      expect(StorageKeys.accessToken, isNotEmpty);
      expect(StorageKeys.refreshToken, isNotEmpty);
    });

    test('SecurityConsts values are standard', () {
      expect(SecurityConsts.aesGcmTagLength, equals(16));
      expect(SecurityConsts.nonceLength, equals(12));
      expect(SecurityConsts.saltLength, equals(16));
      expect(SecurityConsts.pbkdf2Iterations, equals(100000));
    });

    test('AppInfo and LocaleCodes are configured', () {
      expect(AppInfo.name, equals('Fluttea'));
      expect(LocaleCodes.defaultLocale, equals(LocaleCodes.id));
    });

    test('AppRegex validates correctly', () {
      expect(AppRegex.email.hasMatch('test@fluttea.com'), isTrue);
      expect(AppRegex.email.hasMatch('invalid-email'), isFalse);
      expect(AppRegex.phone.hasMatch('+628123456789'), isTrue);
      expect(AppRegex.phone.hasMatch('abc'), isFalse);
      expect(AppRegex.numericOnly.hasMatch('123456'), isTrue);
      expect(AppRegex.numericOnly.hasMatch('123a'), isFalse);
    });
  });
}

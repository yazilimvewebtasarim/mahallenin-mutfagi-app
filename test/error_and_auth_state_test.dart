import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sandbox_app/core/utils/error_utils.dart';
import 'package:sandbox_app/core/services/session_service.dart';
import 'package:sandbox_app/features/auth/controllers/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorUtils Tests', () {
    test('Translates connection timeout to Turkish message', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      final msg = ErrorUtils.toUserFriendlyMessage(dioErr);
      expect(msg, contains('zaman aşımına'));
      expect(msg, isNot(contains('Mozilla')));
    });

    test('Translates 401 unauthorized to login prompt', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/orders'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/orders'),
          statusCode: 401,
        ),
      );
      final msg = ErrorUtils.toUserFriendlyMessage(dioErr);
      expect(msg, contains('oturum açmanız'));
    });

    test('Translates raw exception strings containing DioException without leaking stack trace', () {
      const rawException = 'Exception: Özel talepleriniz yüklenemedi: DioException [bad response]: This exception was thrown because the response has a status code of 401... Read more at mozilla.org';
      final msg = ErrorUtils.toUserFriendlyMessage(rawException);
      expect(msg, isNot(contains('mozilla.org')));
      expect(msg, contains('oturum'));
    });
  });

  group('SessionService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Saves and loads tokens including refreshToken', () async {
      await SessionService.save(
        token: 'access-123',
        refreshToken: 'refresh-456',
        role: 'customer',
        userId: 'usr-1',
        name: 'Ahmet Yılmaz',
      );

      final session = await SessionService.load();
      expect(session['token'], 'access-123');
      expect(session['refreshToken'], 'refresh-456');
      expect(session['role'], 'customer');
      expect(session['name'], 'Ahmet Yılmaz');

      final hasSession = await SessionService.hasSession();
      expect(hasSession, isTrue);

      await SessionService.clear();
      final hasSessionAfterClear = await SessionService.hasSession();
      expect(hasSessionAfterClear, isFalse);
    });
  });

  group('AuthController Validation Tests', () {
    late AuthController controller;

    setUp(() {
      controller = AuthController();
      controller.selectedRole = 'customer';
      controller.isLoginMode.value = false;
    });

    test('Rejects invalid phone, tc and password during registration', () async {
      controller.nameCtrl.text = 'A'; // too short
      controller.tcCtrl.text = '123'; // not 11 digits
      controller.phoneCtrl.text = '05551234567'; // starts with 0
      controller.emailCtrl.text = 'invalid-email';
      controller.passwordCtrl.text = '123'; // < 6 chars

      await controller.submit();

      expect(controller.nameError.value, isNotNull);
      expect(controller.tcError.value, isNotNull);
      expect(controller.phoneError.value, isNotNull);
      expect(controller.emailError.value, isNotNull);
      expect(controller.passwordError.value, isNotNull);
    });

    test('Clears field errors', () {
      controller.nameError.value = 'Hata';
      controller.clearFieldErrors();
      expect(controller.nameError.value, isNull);
    });
  });
}

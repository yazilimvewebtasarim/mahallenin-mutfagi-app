import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../constants/api_constants.dart';
import '../routes/app_routes.dart';
import 'session_service.dart';

class ApiClient {
  static Dio? _instance;
  static bool _isShowingAuthDialog = false;

  static Dio get dio {
    if (_instance != null) return _instance!;

    _instance = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 35),
        receiveTimeout: const Duration(seconds: 35),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _instance!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await SessionService.load();
          final token = session['token'];
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final isAlreadyRetry = error.requestOptions.extra['is_retry'] == true;

          // 401 Unauthorized handling
          if (statusCode == 401 && !isAlreadyRetry) {
            final refreshToken = await SessionService.getRefreshToken();
            
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Try silent token refresh
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: ApiConstants.baseUrl,
                    connectTimeout: const Duration(seconds: 15),
                    receiveTimeout: const Duration(seconds: 15),
                  ),
                );
                final refreshResponse = await refreshDio.post(
                  ApiConstants.authRefreshTokenEndpoint,
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200 && refreshResponse.data['success'] == true) {
                  final newToken = refreshResponse.data['token'] as String;
                  final newRefreshToken = refreshResponse.data['refreshToken'] as String?;
                  await SessionService.updateTokens(
                    token: newToken,
                    refreshToken: newRefreshToken,
                  );

                  // Retry the original request
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newToken';
                  retryOptions.extra['is_retry'] = true;

                  final retryResponse = await _instance!.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                // Refresh failed, proceed to session expiry
              }
            }

            // If refresh not possible or failed:
            final hadToken = await SessionService.hasSession();
            if (hadToken) {
              await SessionService.clear();
            }

            // Prompt user with a polite dialog if not already open
            _showAuthRequiredDialog(isExpired: hadToken);

            // Pass a sanitized, friendly exception to prevent stack trace/Mozilla text
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: hadToken
                    ? 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.'
                    : 'Bu işlemi gerçekleştirmek için giriş yapmanız gerekmektedir.',
                message: hadToken
                    ? 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.'
                    : 'Bu işlemi gerçekleştirmek için giriş yapmanız gerekmektedir.',
              ),
            );
          }

          // Format timeout errors pleasantly
          if (error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: 'Sunucu yanıt vermedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                message: 'Sunucu yanıt vermedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );

    return _instance!;
  }

  static void _showAuthRequiredDialog({bool isExpired = false}) {
    if (_isShowingAuthDialog) return;
    _isShowingAuthDialog = true;

    // Run on next microtask so Get overlay is ready
    Future.microtask(() {
      Get.defaultDialog(
        title: isExpired ? 'Oturum Süresi Doldu' : 'Giriş Yapmalısınız',
        middleText: isExpired
            ? 'Güvenliğiniz için oturumunuz sonlandırıldı. Lütfen tekrar giriş yapın.'
            : 'Bu özelliği kullanabilmek için lütfen hesabınıza giriş yapın veya kayıt olun.',
        textConfirm: 'Giriş Yap',
        textCancel: 'Daha Sonra',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFEA004B),
        onConfirm: () {
          _isShowingAuthDialog = false;
          Get.back();
          Get.toNamed(AppRoutes.login, arguments: 'customer');
        },
        onCancel: () {
          _isShowingAuthDialog = false;
        },
      );
    });
  }
}

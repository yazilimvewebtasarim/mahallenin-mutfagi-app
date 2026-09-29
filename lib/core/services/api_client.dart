import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'session_service.dart';

class ApiClient {
  static Dio? _instance;

  static Dio get dio {
    if (_instance != null) return _instance!;

    _instance = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
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
          // 401 Unauthorized handling can be placed here if needed
          return handler.next(error);
        },
      ),
    );

    return _instance!;
  }
}

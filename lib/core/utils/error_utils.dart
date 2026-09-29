import 'package:dio/dio.dart';

class ErrorUtils {
  static String toUserFriendlyMessage(dynamic error, {String fallback = 'Bir hata oluştu. Lütfen tekrar deneyin.'}) {
    if (error == null) return fallback;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Bağlantı zaman aşımına uğradı. Sunucu yanıt vermedi, lütfen tekrar deneyin.';

        case DioExceptionType.connectionError:
          return 'İnternet bağlantısı kurulamadı. Lütfen ağ bağlantınızı kontrol edin.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (data is Map<String, dynamic>) {
            final serverMsg = data['message'] ?? data['error'];
            if (serverMsg is String && serverMsg.isNotEmpty && !serverMsg.startsWith('DioException')) {
              return serverMsg;
            }
          }

          if (statusCode == 401) {
            return 'Bu işlem için oturum açmanız gerekmektedir.';
          } else if (statusCode == 403) {
            return 'Bu işlemi yapmaya yetkiniz bulunmuyor.';
          } else if (statusCode == 404) {
            return 'Aradığınız kayıt bulunamadı.';
          } else if (statusCode == 409) {
            return 'Bir çakışma oluştu. Lütfen bilgileri kontrol edin.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Sunucuda geçici bir aksaklık oluştu. Lütfen biraz sonra tekrar deneyin.';
          }
          return fallback;

        case DioExceptionType.cancel:
          return 'İstek iptal edildi.';

        case DioExceptionType.badCertificate:
          return 'Güvenli bağlantı doğrulanamadı.';

        case DioExceptionType.unknown:
        default:
          final msg = error.message ?? '';
          if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
            return 'İnternet bağlantısı bulunamadı. Lütfen ağınızı kontrol edin.';
          }
          return fallback;
      }
    }

    final str = error.toString();
    // Clean common prefixes
    var clean = str.replaceFirst(RegExp(r'^Exception:\s*'), '');
    if (clean.contains('DioException [bad response]') || clean.contains('developer.mozilla.org')) {
      if (clean.contains('401')) {
        return 'Bu işlem için oturum açmanız gerekmektedir.';
      }
      return 'Sunucuyla iletişim kurulurken bir hata oluştu.';
    }
    if (clean.contains('DioException [receive timeout]') || clean.contains('DioException [connection timeout]')) {
      return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }

    return clean.isNotEmpty ? clean : fallback;
  }
}

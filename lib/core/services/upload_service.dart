import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UploadService {
  static Dio get _dio => ApiClient.dio;


  /// Resim veya PDF dosyasını Firebase Storage'a yükler, public URL döner
  static Future<String> uploadFile(File file, {String folder = 'general'}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'folder': folder,
      });
      final response = await _dio.post('/upload', data: formData);
      if (response.data['success'] == true) {
        return response.data['url'] as String;
      }
      throw Exception('Yükleme başarısız: ${response.data}');
    } catch (e) {
      throw Exception('Dosya yüklenemedi: $e');
    }
  }
}

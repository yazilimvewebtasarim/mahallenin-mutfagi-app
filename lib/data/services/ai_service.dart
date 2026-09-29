import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class AiService {
  final Dio _dio;

  AiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<String>> detectAllergens(String ingredients) async {
    try {
      final response = await _dio.post('/api/v1/ai/detect-allergens', data: {
        'ingredients': ingredients,
      });
      return List<String>.from(response.data['allergens'] ?? []);
    } catch (e) {
      throw Exception('Failed to detect allergens');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodSuggestions() async {
    try {
      final response = await _dio.get('/api/v1/ai/food-suggestions');
      return List<Map<String, dynamic>>.from(response.data['suggestions'] ?? []);
    } catch (e) {
      throw Exception('Failed to get food suggestions');
    }
  }

  Future<List<Map<String, dynamic>>> getMenuSuggestions() async {
    try {
      final response = await _dio.get('/api/v1/ai/menu-suggestions');
      return List<Map<String, dynamic>>.from(response.data['suggestions'] ?? []);
    } catch (e) {
      throw Exception('Failed to get menu suggestions');
    }
  }
}

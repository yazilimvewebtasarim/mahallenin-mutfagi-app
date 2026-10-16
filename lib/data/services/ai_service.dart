import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class AiService {
  final Dio _dio;

  AiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<String>> detectAllergens(String ingredients) async {
    try {
      final ingredientList = ingredients
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final response = await _dio.post('${ApiConstants.aiEndpoint}/detect-allergens', data: {
        'ingredients': ingredientList,
      });
      return List<String>.from(response.data['allergens'] ?? []);
    } catch (e) {
      throw Exception('Failed to detect allergens');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodSuggestions() async {
    try {
      final response = await _dio.get('${ApiConstants.aiEndpoint}/food-suggestions');
      return List<Map<String, dynamic>>.from(response.data['suggestions'] ?? []);
    } catch (e) {
      throw Exception('Failed to get food suggestions');
    }
  }

  Future<List<Map<String, dynamic>>> getMenuSuggestions() async {
    try {
      final response = await _dio.get('${ApiConstants.aiEndpoint}/menu-suggestions');
      return List<Map<String, dynamic>>.from(response.data['suggestions'] ?? []);
    } catch (e) {
      throw Exception('Failed to get menu suggestions');
    }
  }
}

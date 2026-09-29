import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/food_model.dart';
import '../models/cart_item_model.dart';
import '../models/chef_model.dart';

class CustomerService {
  final Dio _dio;

  CustomerService({Dio? dio}) : _dio = dio ?? ApiClient.dio;


  Future<List<ChefModel>> getChefs() async {
    try {
      final response = await _dio.get(ApiConstants.customerChefsEndpoint);
      final map = response.data as Map<String, dynamic>;
      final rawList = map['data'] as List;
      return rawList.map((item) => ChefModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Aşçılar yüklenemedi: $e');
    }
  }

  Future<void> createCustomRequest({
    String? customerId,
    required String title,
    required String description,
    double? budget,
    String? targetChefId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'description': description,
        'budget': budget,
        'targetChefId': targetChefId,
      };
      if (customerId != null) {
        body['customerId'] = customerId;
      }
      await _dio.post(ApiConstants.customerRequestsEndpoint, data: body);
    } catch (e) {
      throw Exception('Talep oluşturulamadı: $e');
    }
  }

  Future<ChefModel> getChef(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.customerChefsEndpoint}/$id');
      return ChefModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Aşçı bilgisi yüklenemedi: $e');
    }
  }

  Future<List<FoodModel>> getFoods({String? query, String? category, String? chefId}) async {
    try {
      final response = await _dio.get(
        ApiConstants.customerFoodsEndpoint,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (category != null && category != 'Tümü') 'category': category,
          'chefId': chefId,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final dynamic rawList = map['foods'] ?? map['data'] ?? map['items'];
        if (rawList is List) {
          return rawList
              .map((item) => FoodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (response.data is List) {
        return (response.data as List)
            .map((item) => FoodModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (_) {
      try {
        final fallbackResponse = await _dio.get(ApiConstants.chefFoodsEndpoint);
        if (fallbackResponse.data is Map<String, dynamic>) {
          final map = fallbackResponse.data as Map<String, dynamic>;
          final dynamic rawList = map['foods'] ?? map['data'] ?? map['items'];
          if (rawList is List) {
            return rawList
                .map((item) => FoodModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        } else if (fallbackResponse.data is List) {
           return (fallbackResponse.data as List)
                .map((item) => FoodModel.fromJson(item as Map<String, dynamic>))
                .toList();
        }
      } catch (_) {}
      return [];
    } catch (e) {
      throw Exception('Yemekler yüklenemedi: $e');
    }
  }

  Future<Map<String, dynamic>> syncCart({
    required List<CartItemModel> items,
    String? chefId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.customerCartEndpoint,
        data: {
          'items': items.map((e) => {
            'foodId': e.food.id ?? e.id,
            'isim': e.food.isim,
            'fiyat': e.food.fiyat,
            'quantity': e.quantity,
            'chefId': e.food.chefId,
            'selectedExtras': e.selectedExtras.map((ex) => ex.toJson()).toList(),
            if (e.note != null) 'note': e.note,
          }).toList(),
          'chefId': chefId,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            e.message ??
            'Sepet senkronizasyonunda hata oluştu',
      );
    } catch (e) {
      throw Exception('Sepet senkronizasyonu başarısız: $e');
    }
  }
}

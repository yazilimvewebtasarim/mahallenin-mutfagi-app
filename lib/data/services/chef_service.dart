import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/food_model.dart';

class ChefService {
  final Dio _dio;

  ChefService({Dio? dio}) : _dio = dio ?? ApiClient.dio;


  Future<List<FoodModel>> getFoods({String? chefId}) async {
    try {
      final response = await _dio.get(
        ApiConstants.chefFoodsEndpoint,
        queryParameters: chefId != null ? {'chefId': chefId} : null,
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
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            e.message ??
            'Yemekler alınırken bir ağ hatası oluştu',
      );
    } catch (e) {
      throw Exception('Yemekler yüklenemedi: $e');
    }
  }

  Future<FoodModel> addFood(FoodModel food) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefFoodsEndpoint,
        data: food.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final dynamic item = map['food'] ?? map['data'] ?? map;
        if (item is Map<String, dynamic>) {
          return FoodModel.fromJson(item);
        }
      }
      return food;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            e.message ??
            'Yemek eklenirken bir ağ hatası oluştu',
      );
    } catch (e) {
      throw Exception('Yemek eklenemedi: $e');
    }
  }

  Future<bool> deleteFood(String id) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.chefFoodsEndpoint}/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            e.message ??
            'Yemek silinirken bir ağ hatası oluştu',
      );
    } catch (e) {
      throw Exception('Yemek silinemedi: $e');
    }
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get(ApiConstants.chefSubscriptionStatus);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message ?? 'Abonelik durumu alınırken hata oluştu',
      );
    } catch (e) {
      throw Exception('Abonelik durumu yüklenemedi: $e');
    }
  }

  Future<Map<String, dynamic>> initializeSubscriptionCheckout({int rights = 10}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefSubscriptionInitCheckout,
        data: {'rights': rights},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message ?? 'Ödeme sayfası başlatılamadı',
      );
    } catch (e) {
      throw Exception('Ödeme sayfası başlatılamadı: $e');
    }
  }

  Future<Map<String, dynamic>> initializeShopierCheckout({int rights = 10}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefSubscriptionInitShopier,
        data: {'rights': rights},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message ?? 'Shopier ödeme sayfası başlatılamadı',
      );
    } catch (e) {
      throw Exception('Shopier ödeme sayfası başlatılamadı: $e');
    }
  }

  Future<bool> notifyPayment({int rights = 10}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefSubscriptionNotify,
        data: {'rights': rights},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message ?? 'Ödeme bildirimi yapılırken hata oluştu',
      );
    } catch (e) {
      throw Exception('Ödeme bildirimi başarısız: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCustomRequests() async {
    try {
      final response = await _dio.get(ApiConstants.chefRequestsEndpoint);
      if (response.data is Map<String, dynamic>) {
        final rawList = response.data['data'] as List?;
        if (rawList != null) {
          return List<Map<String, dynamic>>.from(rawList);
        }
      }
      return [];
    } catch (e) {
      throw Exception('Talepler yüklenemedi: $e');
    }
  }

  Future<bool> submitBid({required String requestId, required double price, String? note}) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.chefRequestsEndpoint}/$requestId/bid',
        data: {
          'price': price,
          'note': note ?? '',
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Teklif iletilemedi: $e');
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      final response = await _dio.get(ApiConstants.chefFinanceEndpoint);
      if (response.data is Map<String, dynamic> && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return {'balance': 0.0, 'iban': '', 'withdrawals': []};
    } catch (e) {
      throw Exception('Finans bilgileri alınamadı: $e');
    }
  }

  Future<bool> updateIban(String iban) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefFinanceUpdateIban,
        data: {'iban': iban},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('IBAN güncellenemedi: $e');
    }
  }

  Future<bool> withdraw(double amount) async {
    try {
      final response = await _dio.post(
        ApiConstants.chefFinanceWithdraw,
        data: {'amount': amount},
      );
      return response.statusCode == 200 || response.data['success'] == true;
    } catch (e) {
      throw Exception('Para çekme talebi başarısız: $e');
    }
  }
}


import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio;

  OrderService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        ApiConstants.ordersEndpoint,
        data: orderData,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order'] ?? response.data);
      }
      throw Exception('Failed to create order');
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getCustomerOrders() async {
    try {
      final response = await _dio.get(ApiConstants.ordersEndpoint);
      if (response.data is List) {
        return (response.data as List).map((e) => OrderModel.fromJson(e)).toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
      } else if (response.data['orders'] is List) {
        return (response.data['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get customer orders: $e');
    }
  }

  Future<List<OrderModel>> getChefOrders() async {
    try {
      final response = await _dio.get(ApiConstants.chefOrdersEndpoint);
      if (response.data is List) {
        return (response.data as List).map((e) => OrderModel.fromJson(e)).toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
      } else if (response.data['orders'] is List) {
        return (response.data['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get chef orders: $e');
    }
  }


  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.chefOrdersEndpoint}/$orderId/status',
        data: {'status': status},
      );
      return OrderModel.fromJson(response.data['order'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}

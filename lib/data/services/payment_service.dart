import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';

class PaymentService {
  final Dio _dio;

  PaymentService({Dio? dio}) : _dio = dio ?? ApiClient.dio;


  Future<void> createCashPayment(String orderId) async {
    try {
      await _dio.post(
        '${ApiConstants.paymentEndpoint}/create-cash',
        data: {'orderId': orderId},
      );
    } catch (e) {
      throw Exception('Kapıda ödeme oluşturulamadı: $e');
    }
  }

  Future<String> initCheckoutForm(String orderId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.paymentEndpoint}/checkout-form/init',
        data: {'orderId': orderId},
      );
      // Returns a payment HTML or url
      return response.data['paymentPageUrl'] ?? response.data['htmlContent'] ?? '';
    } catch (e) {
      throw Exception('Ödeme formu başlatılamadı: $e');
    }
  }
}

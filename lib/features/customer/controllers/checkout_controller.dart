import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/order_service.dart';
import '../../../data/services/payment_service.dart';
import 'cart_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/error_utils.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final CartController cartController = Get.find<CartController>();
  
  final deliveryAddress = ''.obs;
  final selectedPaymentMethod = 'cash'.obs; // 'cash' or 'credit_card'
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_addresses');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map && first['address'] != null) {
            deliveryAddress.value = first['address'].toString();
          }
        }
      }
    } catch (_) {}
  }

  void placeOrder() async {
    if (cartController.items.isEmpty) {
      Get.snackbar('Hata', 'Sepetiniz boş');
      return;
    }
    if (deliveryAddress.value.trim().isEmpty) {
      Get.snackbar('Hata', 'Lütfen teslimat adresi giriniz');
      return;
    }

    try {
      isLoading.value = true;
      final session = await SessionService.load();
      final customerId = session['userId'] ?? SessionService.currentUserId ?? '';
      final customerName = session['name'] ?? SessionService.currentUserName ?? 'Müşteri';

      final orderData = {
        'customerId': customerId,
        'chefId': cartController.items.first.food.chefId ?? '',
        'items': cartController.items.map((e) => {
          'foodId': e.food.id,
          'quantity': e.quantity,
          'note': e.note,
          'selectedExtras': e.selectedExtras.map((ex) => ex.toJson()).toList()
        }).toList(),
        'totalAmount': cartController.grandTotal,
        'deliveryAddress': deliveryAddress.value.trim(),
        'customerName': customerName,
        'paymentMethod': selectedPaymentMethod.value,
      };
      
      final order = await _orderService.createOrder(orderData);
      
      if (selectedPaymentMethod.value == 'cash') {
        await _paymentService.createCashPayment(order.id!);
        cartController.clearCart();
        Get.offNamed(AppRoutes.customerOrders);
        Get.snackbar('Başarılı', 'Siparişiniz alındı');
      } else {
        await _paymentService.initCheckoutForm(order.id!, amount: order.totalAmount > 0 ? order.totalAmount : cartController.grandTotal);
        cartController.clearCart();
        Get.offNamed(AppRoutes.customerOrders);
        Get.snackbar('Başarılı', 'Siparişiniz alındı.');
      }
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Sipariş oluşturulamadı.');
      Get.snackbar('Hata', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

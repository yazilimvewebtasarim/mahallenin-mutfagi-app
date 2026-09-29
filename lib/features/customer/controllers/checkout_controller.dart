import 'package:get/get.dart';

import '../../../data/services/order_service.dart';
import '../../../data/services/payment_service.dart';
import 'cart_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/error_utils.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final CartController cartController = Get.find<CartController>();
  
  final deliveryAddress = ''.obs;
  final selectedPaymentMethod = 'cash'.obs; // 'cash' or 'credit_card'
  final isLoading = false.obs;

  void placeOrder() async {
    if (cartController.items.isEmpty) {
      Get.snackbar('Hata', 'Sepetiniz boş');
      return;
    }
    if (deliveryAddress.value.isEmpty) {
      Get.snackbar('Hata', 'Lütfen teslimat adresi giriniz');
      return;
    }

    try {
      isLoading.value = true;
      final orderData = {
        'customerId': 'customer1',
        'chefId': cartController.items.first.food.chefId ?? 'chef1',
        'items': cartController.items.map((e) => {
          'foodId': e.food.id,
          'quantity': e.quantity,
          'note': e.note,
          'selectedExtras': e.selectedExtras.map((ex) => ex.toJson()).toList()
        }).toList(),
        'totalAmount': cartController.grandTotal,
        'deliveryAddress': deliveryAddress.value,
        'customerName': 'Test Customer',
        'paymentMethod': selectedPaymentMethod.value,
      };
      
      final order = await _orderService.createOrder(orderData);
      
      if (selectedPaymentMethod.value == 'cash') {
        await _paymentService.createCashPayment(order.id!);
        cartController.clearCart();
        Get.offNamed(AppRoutes.customerOrders);
        Get.snackbar('Başarılı', 'Siparişiniz alındı');
      } else {
        await _paymentService.initCheckoutForm(order.id!);
        cartController.clearCart();
        Get.offNamed(AppRoutes.customerOrders);
        Get.snackbar('Başarılı', 'Siparişiniz alındı. (Kredi kartı simüle edildi)');
      }
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Sipariş oluşturulamadı.');
      Get.snackbar('Hata', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

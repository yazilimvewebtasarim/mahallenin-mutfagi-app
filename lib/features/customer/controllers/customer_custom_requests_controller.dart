import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/custom_request_model.dart';
import '../../../data/services/customer_service.dart';

class CustomerCustomRequestsController extends GetxController {
  final CustomerService _customerService = CustomerService();

  final requests = <CustomRequestModel>[].obs;
  final isLoading = false.obs;
  final isAcceptingBid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      final result = await _customerService.getCustomerRequests();
      requests.value = result;
    } catch (e) {
      Get.snackbar('Hata', 'Talepleriniz yüklenemedi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptBid({required String requestId, required String chefId, required String chefName}) async {
    try {
      isAcceptingBid.value = true;
      final result = await _customerService.acceptBid(requestId, chefId);
      final rawOrderId = result['orderId']?.toString() ?? '';
      final shortOrderId = rawOrderId.length >= 8 ? '#${rawOrderId.substring(0, 8)} ' : '';

      Get.defaultDialog(
        title: 'Tebrikler! 🎉',
        middleText: '$chefName tarafından verilen teklifi kabul ettiniz. $shortOrderId nolu siparişiniz oluşturuldu ve aşçının mutfağına iletildi.',
        textConfirm: 'Siparişimi Takip Et',
        textCancel: 'Kapat',
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
        onConfirm: () {
          Get.back(); // close dialog
          Get.toNamed(AppRoutes.customerOrders);
        },
      );

      await fetchRequests();
    } catch (e) {
      Get.snackbar('Hata', 'Teklif kabul edilemedi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAcceptingBid.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/error_utils.dart';
import '../../../data/models/custom_request_model.dart';
import '../../../data/services/customer_service.dart';

class CustomerCustomRequestsController extends GetxController {
  final CustomerService _customerService = CustomerService();

  final requests = <CustomRequestModel>[].obs;
  final isLoading = false.obs;
  final isGuest = false.obs;
  final errorMessage = ''.obs;
  final isAcceptingBid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final hasAuth = await SessionService.hasSession();
      if (!hasAuth) {
        isGuest.value = true;
        requests.clear();
        return;
      }
      isGuest.value = false;

      final result = await _customerService.getCustomerRequests();
      requests.value = result;
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Talepleriniz yüklenemedi.');
      errorMessage.value = friendly;
      Get.snackbar('Bilgi', friendly, snackPosition: SnackPosition.BOTTOM);
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
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Teklif kabul edilemedi.');
      Get.snackbar('Hata', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAcceptingBid.value = false;
    }
  }
}

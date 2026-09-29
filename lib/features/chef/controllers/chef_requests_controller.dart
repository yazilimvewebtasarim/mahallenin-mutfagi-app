import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/chef_service.dart';

class ChefRequestsController extends GetxController {
  final ChefService _chefService = ChefService();

  final requests = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmittingBid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      final result = await _chefService.getCustomRequests();
      requests.value = result;
    } catch (e) {
      Get.snackbar('Hata', 'Talepler yüklenemedi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitBid({required String requestId, required double price, String? note}) async {
    try {
      isSubmittingBid.value = true;
      final success = await _chefService.submitBid(requestId: requestId, price: price, note: note);
      if (success) {
        Get.snackbar(
          'Tebrikler!',
          'Teklifiniz müşteriye başarıyla iletildi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchRequests();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Hata', 'Teklif iletilemedi: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmittingBid.value = false;
    }
  }
}

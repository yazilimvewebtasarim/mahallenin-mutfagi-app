import 'package:get/get.dart';
import '../../../data/services/review_service.dart';

class OrderReviewController extends GetxController {
  final ReviewService _reviewService = ReviewService();
  
  final rating = 0.0.obs;
  final comment = ''.obs;
  final isLoading = false.obs;

  final orderId = Get.arguments?['orderId'] ?? '';
  final chefId = Get.arguments?['chefId'] ?? '';

  void submitReview() async {
    if (rating.value == 0) {
      Get.snackbar('Hata', 'Lütfen bir puan veriniz.');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'orderId': orderId,
        'chefId': chefId,
        'customerId': 'customer1',
        'rating': rating.value,
        'comment': comment.value,
      };
      await _reviewService.submitReview(data);
      Get.back();
      Get.snackbar('Başarılı', 'Değerlendirmeniz gönderildi.');
    } catch (e) {
      Get.snackbar('Hata', 'Değerlendirme gönderilemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

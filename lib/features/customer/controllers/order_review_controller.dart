import 'package:get/get.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/error_utils.dart';
import '../../../data/services/review_service.dart';

class OrderReviewController extends GetxController {
  final ReviewService _reviewService = ReviewService();
  
  final rating = 0.0.obs;
  final comment = ''.obs;
  final isLoading = false.obs;

  final orderId = Get.arguments?['orderId'] ?? '';
  final chefId = Get.arguments?['chefId'] ?? '';

  void submitReview() async {
    if (rating.value <= 0) {
      Get.snackbar('Hata', 'Lütfen bir puan veriniz.');
      return;
    }

    try {
      isLoading.value = true;
      final session = await SessionService.load();
      final customerId = session['userId'] ?? SessionService.currentUserId ?? '';
      final data = {
        'orderId': orderId,
        'chefId': chefId,
        'customerId': customerId,
        'rating': rating.value.round().clamp(1, 5),
        'comment': comment.value.trim(),
      };
      await _reviewService.submitReview(data);
      Get.back();
      Get.snackbar('Başarılı', 'Değerlendirmeniz gönderildi.');
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Değerlendirme gönderilemedi.');
      Get.snackbar('Hata', friendly);
    } finally {
      isLoading.value = false;
    }
  }
}

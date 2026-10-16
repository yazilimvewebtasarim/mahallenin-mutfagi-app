import 'package:get/get.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/error_utils.dart';
import '../../../data/services/review_service.dart';

class ChefReviewsController extends GetxController {
  final ReviewService _reviewService = ReviewService();
  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  void fetchReviews() async {
    try {
      isLoading.value = true;
      final session = await SessionService.load();
      final chefId = session['userId'] ?? SessionService.currentUserId ?? '';
      if (chefId.isEmpty) {
        reviews.clear();
        return;
      }
      final data = await _reviewService.getChefReviews(chefId);
      reviews.assignAll(data);
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Değerlendirmeler alınamadı.');
      Get.snackbar('Bilgi', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

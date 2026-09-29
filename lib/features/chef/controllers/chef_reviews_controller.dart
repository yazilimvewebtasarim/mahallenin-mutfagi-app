import 'package:get/get.dart';
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
      final data = await _reviewService.getChefReviews('chef1');
      reviews.assignAll(data);
    } catch (e) {
      Get.snackbar('Hata', 'Değerlendirmeler alınamadı: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

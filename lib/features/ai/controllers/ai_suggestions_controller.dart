import 'package:get/get.dart';
import '../../../data/services/ai_service.dart';

class AiSuggestionsController extends GetxController {
  final AiService _aiService = AiService();
  
  var isLoading = false.obs;
  var suggestions = <Map<String, dynamic>>[].obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuggestions();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    isLoading.value = true;
    try {
      if (selectedTab.value == 0) {
        final data = await _aiService.getFoodSuggestions();
        suggestions.value = data;
      } else {
        final data = await _aiService.getMenuSuggestions();
        suggestions.value = data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch suggestions');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<String>> detectAllergens(String ingredients) async {
    try {
      return await _aiService.detectAllergens(ingredients);
    } catch (e) {
      Get.snackbar('Error', 'Failed to detect allergens');
      return [];
    }
  }
}

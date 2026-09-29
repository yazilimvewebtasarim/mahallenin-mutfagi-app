import 'package:get/get.dart';
import '../../../data/models/chef_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/customer_service.dart';

class ChefStorefrontController extends GetxController {
  final Rx<ChefModel?> chef = Rx<ChefModel?>(null);
  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final String? chefId = Get.arguments as String?;
    if (chefId != null) {
      loadData(chefId);
    } else {
      errorMessage.value = 'Geçersiz aşçı';
    }
  }

  Future<void> loadData(String chefId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final service = Get.find<CustomerService>();
      final fetchedChef = await service.getChef(chefId);
      final fetchedFoods = await service.getFoods(chefId: chefId);
      chef.value = fetchedChef;
      foods.value = fetchedFoods;
    } catch (e) {
      errorMessage.value = 'Hata: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import '../../../data/models/chef_model.dart';
import '../../../data/services/customer_service.dart';

class DiscoveryController extends GetxController {
  final RxList<ChefModel> allChefs = <ChefModel>[].obs;
  final RxList<ChefModel> filteredChefs = <ChefModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChefs();
  }

  Future<void> fetchChefs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final service = Get.find<CustomerService>();
      final chefs = await service.getChefs();
      allChefs.value = chefs;
      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    var list = allChefs.toList();
    
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((f) => f.isimSoyad.toLowerCase().contains(q) ).toList();
    }
    
    filteredChefs.value = list;
  }
}

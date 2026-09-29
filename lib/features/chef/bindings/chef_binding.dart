import 'package:get/get.dart';
import '../../../data/services/chef_service.dart';
import '../controllers/chef_controller.dart';
import '../controllers/chef_orders_controller.dart';

class ChefBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChefService>(() => ChefService());
    Get.lazyPut<ChefController>(() => ChefController());
    Get.lazyPut<ChefOrdersController>(() => ChefOrdersController());
  }
}

import 'package:get/get.dart';
import '../../../data/services/customer_service.dart';
import '../controllers/cart_controller.dart';
import '../controllers/discovery_controller.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/customer_orders_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerService>(() => CustomerService());
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(CartController(), permanent: true);
    }
    Get.lazyPut<DiscoveryController>(() => DiscoveryController());
    Get.lazyPut<CheckoutController>(() => CheckoutController());
    Get.lazyPut<CustomerOrdersController>(() => CustomerOrdersController());
  }
}

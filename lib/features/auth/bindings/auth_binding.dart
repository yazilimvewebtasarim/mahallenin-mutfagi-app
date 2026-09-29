import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/role_controller.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

class RoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleController>(() => RoleController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

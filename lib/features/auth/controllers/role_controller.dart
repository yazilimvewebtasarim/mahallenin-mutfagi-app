import 'package:get/get.dart';
import '../views/login_register_view.dart';

class RoleController extends GetxController {
  void selectRole(String role) {
    // role: 'customer' or 'chef'
    Get.to(() => const LoginRegisterView(), arguments: role);
  }
}

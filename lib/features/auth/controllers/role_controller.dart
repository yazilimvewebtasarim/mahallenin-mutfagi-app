import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class RoleController extends GetxController {
  void selectRole(String role) {
    // role: 'customer' or 'chef'
    Get.toNamed(AppRoutes.login, arguments: role);
  }
}

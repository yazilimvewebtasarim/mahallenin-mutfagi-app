import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/session_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Kaydedilmiş oturum var mı kontrol et
    final session = await SessionService.load();
    final token = session['token'];
    final role = session['role'];

    if (token != null && token.isNotEmpty && role != null) {
      // Oturum açık — direkt ana ekrana git
      if (role == 'chef') {
        Get.offAllNamed(AppRoutes.chefMenu);
      } else {
        Get.offAllNamed(AppRoutes.customerDiscovery);
      }
    } else {
      // Oturum yok — rol seçim ekranına git
      Get.offAllNamed(AppRoutes.roleSelect);
    }
  }
}

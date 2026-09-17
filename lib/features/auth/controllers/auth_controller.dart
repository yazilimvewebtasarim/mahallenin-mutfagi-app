import 'package:get/get.dart';
import 'package:dio/dio.dart';

class AuthController extends GetxController {
  final dio = Dio();
  var isLoading = false.obs;
  var isLoginMode = true.obs;
  
  late String selectedRole;

  @override
  void onInit() {
    super.onInit();
    selectedRole = Get.arguments as String? ?? 'customer';
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> submit() async {
    isLoading.value = true;
    try {
      // Mockup Dio request
      await Future.delayed(const Duration(seconds: 2));
      /* 
      final response = await dio.post('https://api.example.com/auth', data: {
        'role': selectedRole,
        'type': isLoginMode.value ? 'login' : 'register'
      }); 
      */
      Get.snackbar('Başarılı', 'İşlem başarıyla gerçekleşti ($selectedRole).', 
        snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', 'Bir hata oluştu.', 
        snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}

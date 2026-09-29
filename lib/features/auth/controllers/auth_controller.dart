import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/upload_service.dart';

class AuthController extends GetxController {
  final dio = Dio();
  var isLoading = false.obs;
  var isLoginMode = true.obs;
  
  late String selectedRole;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final tcCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Aşçı kaydı için mutfak resmi (sadece kamera)
  final Rx<File?> kitchenImage = Rx<File?>(null);
  final _picker = ImagePicker();

  Future<void> pickKitchenImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      kitchenImage.value = File(picked.path);
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectedRole = Get.arguments as String? ?? 'customer';
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> submit() async {
    if (isLoginMode.value) {
      await _login();
    } else {
      await _startRegistration();
    }
  }

  Future<void> _login() async {
    isLoading.value = true;
    try {
      final response = await dio.post('${ApiConstants.baseUrl}/auth/login', data: {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String;
        final role = data['role'] as String? ?? selectedRole;
        final userId = data['userId'] as String? ?? '';

        // Oturumu kalıcı olarak kaydet
        await SessionService.save(token: token, role: role, userId: userId);
        selectedRole = role;

        Get.snackbar(
          'Başarılı',
          'Giriş başarılı.', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA004B),
          colorText: Colors.white,
        );
        _navigateHome();
      }
    } catch (e) {
      Get.snackbar('Hata', 'Email veya şifre hatalı.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startRegistration() async {
    final phone = phoneCtrl.text.trim();
    if (phone.length != 10 || phone.startsWith('0')) {
      Get.snackbar('Hata', 'Telefon numarası başında 0 olmadan tam 10 haneli olmalıdır.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _completeRegistration();
  }

  Future<void> _completeRegistration() async {
    isLoading.value = true;
    try {
      // Aşçı ise mutfak resmini önce yükle
      String? kitchenImageUrl;
      if (selectedRole == 'chef' && kitchenImage.value != null) {
        kitchenImageUrl = await UploadService.uploadFile(kitchenImage.value!, folder: 'kitchens');
      }

      final response = await dio.post('${ApiConstants.baseUrl}/auth/register', data: {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'isim_soyad': nameCtrl.text.trim(),
        'telefon': phoneCtrl.text.trim(),
        'tc_kimlik': tcCtrl.text.trim(),
        'role': selectedRole,
        'mutfakResmiUrl': kitchenImageUrl,
        'isVisible': true,
      });

      // Kayıt sonrası otomatik giriş yap ve token kaydet
      final data = response.data;
      if (data['token'] != null) {
        await SessionService.save(
          token: data['token'],
          role: selectedRole,
          userId: data['userId'] ?? '',
          name: nameCtrl.text.trim(),
        );
      }

      Get.snackbar(
        'Başarılı',
        'Kayıt başarılı.', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEA004B),
        colorText: Colors.white,
      );
      _navigateHome();
    } catch (e) {
      Get.snackbar('Hata', 'Kayıt sırasında bir hata oluştu.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateHome() {
    if (selectedRole == 'chef') {
      Get.offAllNamed(AppRoutes.chefMenu);
    } else {
      Get.offAllNamed(AppRoutes.customerDiscovery);
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    tcCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}

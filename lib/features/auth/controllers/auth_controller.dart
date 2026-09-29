import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/utils/error_utils.dart';

class AuthController extends GetxController {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  var isLoading = false.obs;
  var isLoginMode = true.obs;
  
  late String selectedRole;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final tcCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Alan bazlı hata durumları (Field specific errors)
  final nameError = RxnString();
  final tcError = RxnString();
  final phoneError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final kitchenError = RxnString();

  // Aşçı kaydı için mutfak resmi (sadece kamera)
  final Rx<File?> kitchenImage = Rx<File?>(null);
  final _picker = ImagePicker();

  Future<void> pickKitchenImageFromCamera() async {
    kitchenError.value = null;
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      kitchenImage.value = File(picked.path);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      selectedRole = args['role'] as String? ?? 'customer';
      if (args['isRegister'] == true) {
        isLoginMode.value = false;
      }
    } else if (Get.arguments is String) {
      selectedRole = Get.arguments as String;
    } else {
      selectedRole = 'customer';
    }
  }

  void toggleMode() {
    clearFieldErrors();
    isLoginMode.value = !isLoginMode.value;
  }

  void clearFieldErrors() {
    nameError.value = null;
    tcError.value = null;
    phoneError.value = null;
    emailError.value = null;
    passwordError.value = null;
    kitchenError.value = null;
  }

  Future<void> submit() async {
    clearFieldErrors();
    if (isLoginMode.value) {
      await _login();
    } else {
      await _startRegistration();
    }
  }

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    var hasValidationErr = false;
    if (email.isEmpty) {
      emailError.value = 'Lütfen e-posta adresinizi giriniz.';
      hasValidationErr = true;
    }
    if (password.isEmpty) {
      passwordError.value = 'Lütfen şifrenizi giriniz.';
      hasValidationErr = true;
    }
    if (hasValidationErr) return;

    isLoading.value = true;
    try {
      final response = await dio.post('${ApiConstants.baseUrl}/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String?;
        final role = data['role'] as String? ?? selectedRole;
        final userId = data['userId'] as String? ?? '';
        final name = data['isim_soyad'] as String? ?? '';

        // Oturumu kalıcı olarak kaydet
        await SessionService.save(
          token: token,
          refreshToken: refreshToken,
          role: role,
          userId: userId,
          name: name.isNotEmpty ? name : null,
        );
        selectedRole = role;

        Get.snackbar(
          'Başarılı',
          'Giriş başarılı. Hoş geldiniz!', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA004B),
          colorText: Colors.white,
        );
        _navigateHome();
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : null;
      final msg = serverMsg is String && serverMsg.isNotEmpty
          ? serverMsg
          : 'E-posta veya şifre hatalı.';
      
      Get.snackbar(
        'Giriş Yapılamadı',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Giriş yapılırken bir hata oluştu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _startRegistration() async {
    var hasError = false;

    final name = nameCtrl.text.trim();
    if (name.length < 2) {
      nameError.value = 'Lütfen ad ve soyadınızı eksiksiz giriniz.';
      hasError = true;
    }

    final tc = tcCtrl.text.trim();
    if (tc.length != 11 || !RegExp(r'^[0-9]{11}$').hasMatch(tc)) {
      tcError.value = 'TC Kimlik numarası 11 haneli olmalıdır.';
      hasError = true;
    }

    final phone = phoneCtrl.text.trim();
    if (phone.length != 10 || !phone.startsWith('5')) {
      phoneError.value = 'Telefon numarası 5 ile başlayan 10 haneli olmalıdır (örn: 506...).';
      hasError = true;
    }

    final email = emailCtrl.text.trim();
    if (email.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      emailError.value = 'Geçerli bir e-posta adresi giriniz.';
      hasError = true;
    }

    final password = passwordCtrl.text;
    if (password.length < 6) {
      passwordError.value = 'Şifreniz en az 6 karakter olmalıdır.';
      hasError = true;
    }

    if (selectedRole == 'chef' && kitchenImage.value == null) {
      kitchenError.value = 'Lütfen mutfak/ocak fotoğrafınızı çekiniz.';
      hasError = true;
    }

    if (hasError) return;

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
        'email': emailCtrl.text.trim().toLowerCase(),
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
          refreshToken: data['refreshToken'],
          role: selectedRole,
          userId: data['userId'] ?? '',
          name: nameCtrl.text.trim(),
        );
      }

      Get.snackbar(
        'Başarılı',
        'Hesabınız başarıyla oluşturuldu. Hoş geldiniz!', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEA004B),
        colorText: Colors.white,
      );
      _navigateHome();
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final field = data['field']?.toString();
        final msg = data['message']?.toString() ?? data['error']?.toString() ?? 'Kayıt sırasında bir hata oluştu.';

        if (field == 'email') {
          emailError.value = msg;
        } else if (field == 'telefon') {
          phoneError.value = msg;
        } else if (field == 'tc_kimlik') {
          tcError.value = msg;
        } else if (field == 'password') {
          passwordError.value = msg;
        } else if (field == 'isim_soyad') {
          nameError.value = msg;
        } else {
          Get.snackbar(
            'Kayıt Hatası',
            msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        }
      } else {
        final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Kayıt sırasında bir hata oluştu.');
        Get.snackbar(
          'Kayıt Hatası',
          friendly,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kayıt sırasında beklenmeyen bir hata oluştu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
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

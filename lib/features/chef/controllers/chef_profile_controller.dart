import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/api_client.dart';
import 'package:dio/dio.dart';

class ChefProfileController extends GetxController {

  final Rx<File?> hygieneCertFile = Rx<File?>(null);
  final RxBool isUploading = false.obs;
  final RxBool hasHygieneCert = false.obs;
  final RxString mutfakResmiUrl = ''.obs;
  final _picker = ImagePicker();
  Dio get _dio => ApiClient.dio;


  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final session = await SessionService.load();
      final userId = session['userId'] ?? '';
      if (userId.isEmpty) return;
      final resp = await _dio.get('/customer/chefs/$userId');
      final data = resp.data['data'];
      hasHygieneCert.value = data['hijyenBelgesi'] == true;
      mutfakResmiUrl.value = data['mutfakResmiUrl'] ?? '';
    } catch (_) {}
  }

  Future<void> pickAndUploadHygieneCert() async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hijyen Belgesi Yükle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Belgenin fotoğrafını çekebilir veya galeriden seçebilirsiniz.',
                style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFEA004B)),
              title: const Text('Kamera ile Çek'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFEA004B)),
              title: const Text('Galeriden Seç'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    hygieneCertFile.value = File(picked.path);
    isUploading.value = true;

    try {
      final url = await UploadService.uploadFile(hygieneCertFile.value!, folder: 'hygiene');
      
      // Firebase'de kullanıcı dokümanını güncelle
      final session = await SessionService.load();
      final userId = session['userId'] ?? '';
      await _dio.patch('/auth/profile', data: {
        'userId': userId,
        'hijyenBelgesi': true,
        'hijyenBelgesiUrl': url,
      });
      
      hasHygieneCert.value = true;
      Get.snackbar('Başarılı', 'Hijyen belgeniz yüklendi ve profilinizde görünecek.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Hata', 'Belge yüklenemedi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/chef_service.dart';
import '../../../core/services/upload_service.dart';

class ChefController extends GetxController {
  final ChefService chefService;

  ChefController({ChefService? chefService})
      : chefService = chefService ?? Get.put(ChefService());

  final RxList<FoodModel> foods = <FoodModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Subscription state
  final RxBool isLimitReached = false.obs;
  final RxString ibanInfo = ''.obs;
  final RxInt orderCount = 0.obs;
  final RxInt paidOrderLimit = 0.obs;

  // Form handling
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final allergenController = TextEditingController();
  final imageUrlController = TextEditingController();
  final extrasController = TextEditingController(); // e.g., 'Acılı:10, Lavaş:15'

  // Yemek resmi seçimi
  final Rx<File?> selectedFoodImage = Rx<File?>(null);
  final RxBool isUploadingImage = false.obs;
  final _picker = ImagePicker();

  Future<void> pickFoodImage() async {
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
            const Text('Resim Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      selectedFoodImage.value = File(picked.path);
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkSubscriptionStatus();
    fetchFoods();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    allergenController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final status = await chefService.getSubscriptionStatus();
      orderCount.value = status['orderCount'] ?? 0;
      paidOrderLimit.value = status['paidOrderLimit'] ?? 10;
      ibanInfo.value = status['iban'] ?? 'TR00 0000 0000 0000 0000 0000 00';
      
      if (orderCount.value >= paidOrderLimit.value) {
        isLimitReached.value = true;
      } else {
        isLimitReached.value = false;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> notifyPayment({int rights = 10}) async {
    try {
      final success = await chefService.notifyPayment(rights: rights);
      if (success) {
        await checkSubscriptionStatus();
        await fetchFoods();
        Get.snackbar(
          'Tebrikler!',
          '$rights sipariş hakkı başarıyla tanımlandı. Yemekleriniz vitrinde aktif!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }


  Future<void> fetchFoods() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await chefService.getFoods();
      foods.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Yemek adı zorunludur';
    }
    if (value.trim().length < 2) {
      return 'Yemek adı en az 2 karakter olmalıdır';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Açıklama zorunludur';
    }
    if (value.trim().length < 5) {
      return 'Açıklama en az 5 karakter olmalıdır';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fiyat zorunludur';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Geçerli bir fiyat giriniz (0\'dan büyük)';
    }
    return null;
  }

  String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Porsiyon stoğu zorunludur';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) {
      return 'Geçerli bir porsiyon adedi giriniz';
    }
    return null;
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();
    allergenController.clear();
    imageUrlController.clear();
    extrasController.clear();
    selectedFoodImage.value = null;
  }

  Future<bool> addFood() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isSubmitting.value = true;
    try {
      final double price = double.parse(priceController.text.replaceAll(',', '.'));
      final int stock = int.parse(stockController.text);
      final String allergen = allergenController.text.trim().isEmpty
          ? 'Belirtilmemiş'
          : allergenController.text.trim();
      
      // Resim yükleme: Seçili dosya varsa Firebase'e yükle, yoksa Unsplash varsayılan görseli ata
      String imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
      if (selectedFoodImage.value != null) {
        isUploadingImage.value = true;
        imageUrl = await UploadService.uploadFile(selectedFoodImage.value!, folder: 'foods');
        isUploadingImage.value = false;
      }

      List<ExtraModel> parsedExtras = [];
      if (extrasController.text.trim().isNotEmpty) {
        final parts = extrasController.text.split(',');
        for (var p in parts) {
          final ep = p.split(':');
          if (ep.length == 2) {
            parsedExtras.add(ExtraModel(ad: ep[0].trim(), fiyat: double.tryParse(ep[1].trim()) ?? 0.0));
          }
        }
      }

      final newFood = FoodModel(
        isim: nameController.text.trim(),
        aciklama: descriptionController.text.trim(),
        fiyat: price,
        porsiyonStok: stock,
        alerjenDurumu: allergen,
        resimUrl: imageUrl,
        ekstralar: parsedExtras,
      );

      final createdFood = await chefService.addFood(newFood);
      foods.insert(0, createdFood);
      clearForm();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Yemek menüye başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEA004B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteFood(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Yemeği Sil'),
        content: const Text('Bu yemeği menüden kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await chefService.deleteFood(id);
      if (success) {
        foods.removeWhere((item) => item.id == id);
        Get.snackbar(
          'Başarılı',
          'Yemek menüden silindi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA004B),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

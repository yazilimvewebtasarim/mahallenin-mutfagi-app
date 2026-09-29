import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/customer_service.dart';

class CustomRequestController extends GetxController {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  
  final RxBool isSubmitting = false.obs;
  final String? targetChefId;

  CustomRequestController({this.targetChefId});

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    budgetCtrl.dispose();
    super.onClose();
  }

  Future<void> submitRequest() async {
    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
      Get.snackbar('Hata', 'Lütfen başlık ve açıklama giriniz.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final service = Get.find<CustomerService>();
      await service.createCustomRequest(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        budget: budgetCtrl.text.isNotEmpty ? double.tryParse(budgetCtrl.text) : null,
        targetChefId: targetChefId,
      );
      
      Get.back();
      Get.snackbar('Başarılı', 'Özel yemek talebiniz aşçılara iletildi!', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.green, 
        colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}

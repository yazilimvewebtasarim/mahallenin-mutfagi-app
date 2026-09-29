import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/error_utils.dart';
import '../../../data/services/chef_service.dart';

class ChefFinanceController extends GetxController {
  final ChefService _chefService = ChefService();

  final balance = 0.0.obs;
  final iban = ''.obs;
  final withdrawals = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFinance();
  }

  Future<void> fetchFinance() async {
    try {
      isLoading.value = true;
      final data = await _chefService.getFinanceSummary();
      balance.value = (data['balance'] as num?)?.toDouble() ?? 0.0;
      iban.value = data['iban'] as String? ?? '';
      final rawList = data['withdrawals'] as List?;
      if (rawList != null) {
        withdrawals.assignAll(List<Map<String, dynamic>>.from(rawList));
      }
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Finans bilgileri yüklenemedi.');
      Get.snackbar('Bilgi', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateIban(String newIban) async {
    final cleanIban = newIban.replaceAll(' ', '').toUpperCase();
    if (cleanIban.isEmpty || cleanIban.length < 15) {
      Get.snackbar('Geçersiz IBAN', 'Lütfen geçerli bir IBAN numarası giriniz.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      isActionLoading.value = true;
      final success = await _chefService.updateIban(cleanIban);
      if (success) {
        iban.value = cleanIban;
        Get.snackbar(
          'Başarılı',
          'IBAN bilginiz başarıyla güncellendi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'IBAN güncellenemedi.');
      Get.snackbar('Hata', friendly, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> withdraw(double amount) async {
    if (amount <= 0) {
      Get.snackbar('Hata', 'Lütfen geçerli bir çekim tutarı giriniz.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (amount > balance.value) {
      Get.snackbar(
        'Yetersiz Bakiye',
        'Çekmek istediğiniz tutar (₺$amount) mevcut bakiyenizden (₺${balance.value.toStringAsFixed(2)}) fazladır.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (iban.value.trim().isEmpty) {
      Get.snackbar(
        'IBAN Eksik',
        'Para çekme talebi oluşturmadan önce lütfen bir IBAN kaydediniz.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isActionLoading.value = true;
      final success = await _chefService.withdraw(amount);
      if (success) {
        Get.snackbar(
          'Talep Alındı 🎉',
          '₺${amount.toStringAsFixed(2)} tutarındaki para çekme talebiniz iletildi. En kısa sürede hesabınıza aktarılacaktır.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchFinance();
        return true;
      }
      return false;
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Talep oluşturulamadı.');
      Get.snackbar('Hata', friendly, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/services/customer_service.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxnString activeChefId = RxnString();
  
  final double standardDeliveryFee = 29.90;
  final double freeDeliveryThreshold = 250.00;
  final double standardServiceFee = 4.90;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.itemTotal);
  
  double get deliveryFee => (subtotal == 0 || subtotal >= freeDeliveryThreshold) ? 0.0 : standardDeliveryFee;
  double get serviceFee => subtotal == 0 ? 0.0 : standardServiceFee;
  
  double get grandTotal => subtotal + deliveryFee + serviceFee;
  double get remainingForFreeDelivery => (freeDeliveryThreshold - subtotal).clamp(0.0, freeDeliveryThreshold);

  bool addToCart(FoodModel food, {int quantity = 1, String? note, List<ExtraModel> selectedExtras = const []}) {
    if (activeChefId.value != null && activeChefId.value != food.chefId) {
      _promptKitchenConflict(food, quantity: quantity, note: note, selectedExtras: selectedExtras);
      return false;
    }
    
    activeChefId.value = food.chefId;

    int totalQuantityOfThisFood = items.where((i) => i.food.id == food.id).fold(0, (sum, i) => sum + i.quantity);
    if (totalQuantityOfThisFood + quantity > food.porsiyonStok) {
      Get.snackbar('Stok Yetersiz', 'Bu üründen toplam en fazla ${food.porsiyonStok} adet ekleyebilirsiniz.', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final index = items.indexWhere((i) => (i.food.id ?? '') == (food.id ?? '') && _compareExtras(i.selectedExtras, selectedExtras));
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(CartItemModel(
        id: '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
        food: food,
        quantity: quantity,
        note: note,
        selectedExtras: selectedExtras,
      ));
    }
    return true;
  }

  bool _compareExtras(List<ExtraModel> a, List<ExtraModel> b) {
    if (a.length != b.length) return false;
    for (var extra in a) {
      if (!b.any((e) => e.ad == extra.ad)) return false;
    }
    return true;
  }

  void _promptKitchenConflict(FoodModel food, {int quantity = 1, String? note, List<ExtraModel> selectedExtras = const []}) {
    try {
      Get.defaultDialog(
      title: 'Sepette başka mutfak var',
      middleText: 'Farklı bir mutfaktan ürün eklemek için önce sepeti boşaltmanız gerekir.',
      textConfirm: 'Temizle ve Ekle',
      textCancel: 'Vazgeç',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEA004B),
      onConfirm: () {
        clearCart();
        addToCart(food, quantity: quantity, note: note, selectedExtras: selectedExtras);
        Get.back();
      },
    );
    } catch (_) {}
  }

  void decrementItem(String itemId) {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
      } else {
        removeItem(itemId);
      }
    }
  }
  
  void incrementItem(String itemId) {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      int totalQuantityOfThisFood = items.where((i) => i.food.id == items[index].food.id).fold(0, (sum, i) => sum + i.quantity);
      if (totalQuantityOfThisFood + 1 > items[index].food.porsiyonStok) {
        Get.snackbar('Stok Yetersiz', 'Bu üründen toplam en fazla ${items[index].food.porsiyonStok} adet alabilirsiniz.', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        return;
      }
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    }
  }

  void removeItem(String itemId) {
    items.removeWhere((i) => i.id == itemId);
    if (items.isEmpty) {
      activeChefId.value = null;
    }
  }

  void clearCart() {
    items.clear();
    activeChefId.value = null;
  }

  Future<bool> checkout() async {
    if (items.isEmpty) return false;
    
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    try {
      final service = Get.find<CustomerService>();
      await service.syncCart(items: items.toList(), chefId: activeChefId.value);
      
      Get.back(); // close loader
      
      Get.snackbar(
        'Sipariş Alındı',
        'Siparişiniz başarıyla tamamlandı.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      clearCart();
      return true;
    } catch (e) {
      Get.back(); // close loader
      Get.snackbar('Hata', 'Sipariş tamamlanamadı: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }
}

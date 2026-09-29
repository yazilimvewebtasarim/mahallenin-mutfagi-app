import 'package:flutter_test/flutter_test.dart';
import 'package:sandbox_app/data/models/food_model.dart';
import 'package:sandbox_app/features/customer/controllers/cart_controller.dart';
import 'package:get/get.dart';

void main() {
  late CartController cartController;

  setUp(() {
    cartController = CartController();
  });

  tearDown(() {
    Get.reset();
  });

  test('Adding single item updates quantities correctly', () {
    final food = FoodModel(id: '1', chefId: 'chef1', isim: 'Test Food', fiyat: 100.0, porsiyonStok: 5, resimUrl: '', aciklama: '', alerjenDurumu: '');
    cartController.addToCart(food);

    expect(cartController.items.length, 1);
    expect(cartController.totalItemCount, 1);
    expect(cartController.subtotal, 100.0);
  });

  test('Adding items from different kitchen triggers conflict and does not add', () {
    final food1 = FoodModel(id: '1', chefId: 'chef1', isim: 'Food 1', fiyat: 100.0, porsiyonStok: 5, resimUrl: '', aciklama: '', alerjenDurumu: '');
    final food2 = FoodModel(id: '2', chefId: 'chef2', isim: 'Food 2', fiyat: 150.0, porsiyonStok: 5, resimUrl: '', aciklama: '', alerjenDurumu: '');

    cartController.addToCart(food1);
    final result = cartController.addToCart(food2);

    expect(result, false);
    expect(cartController.items.length, 1);
    expect(cartController.items.first.food.id, '1');
  });

  test('Subtotal and fees calculated correctly', () {
    final food = FoodModel(id: '1', chefId: 'chef1', isim: 'Food', fiyat: 100.0, porsiyonStok: 5, resimUrl: '', aciklama: '', alerjenDurumu: '');
    cartController.addToCart(food, quantity: 2); // 200 TL

    expect(cartController.subtotal, 200.0);
    expect(cartController.deliveryFee, 29.90);
    expect(cartController.serviceFee, 4.90);
    expect(cartController.grandTotal, 200.0 + 29.90 + 4.90);
  });

  test('Free delivery applied when subtotal >= 250', () {
    final food = FoodModel(id: '1', chefId: 'chef1', isim: 'Food', fiyat: 150.0, porsiyonStok: 5, resimUrl: '', aciklama: '', alerjenDurumu: '');
    cartController.addToCart(food, quantity: 2); // 300 TL

    expect(cartController.subtotal, 300.0);
    expect(cartController.deliveryFee, 0.0);
    expect(cartController.serviceFee, 4.90);
    expect(cartController.grandTotal, 300.0 + 0.0 + 4.90);
  });
}

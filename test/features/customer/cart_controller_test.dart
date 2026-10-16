import 'package:flutter_test/flutter_test.dart';
import 'package:sandbox_app/data/models/food_model.dart';
import 'package:sandbox_app/data/models/order_model.dart';
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

  test('OrderModel and CartItemModel parse flat backend order items without crashing', () {
    final backendOrderJson = {
      'id': 'ord_123',
      'customerId': 'cust_1',
      'chefId': 'chef_1',
      'status': 'pending',
      'totalPrice': 230.0,
      'createdAt': '2026-10-16T10:00:00Z',
      'items': [
        {
          'foodId': 'food_1',
          'isim': 'Ev Mantısı',
          'fiyat': 100.0,
          'quantity': 2,
          'selectedExtras': [
            {'ad': 'Yoğurt', 'fiyat': 15.0}
          ]
        }
      ]
    };

    final order = OrderModel.fromJson(backendOrderJson);
    expect(order.id, 'ord_123');
    expect(order.items.length, 1);
    expect(order.items.first.food.id, 'food_1');
    expect(order.items.first.food.isim, 'Ev Mantısı');
    expect(order.items.first.quantity, 2);
    expect(order.items.first.selectedExtras.length, 1);
    expect(order.items.first.selectedExtras.first.ad, 'Yoğurt');
    expect(order.items.first.itemTotal, 200.0);
  });

  test('Incrementing variant quantity respects aggregate food stock across variants', () {
    final food = FoodModel(
      id: 'food_stock_test',
      chefId: 'chef1',
      isim: 'İçli Köfte',
      fiyat: 50.0,
      porsiyonStok: 3,
      resimUrl: '',
      aciklama: '',
      alerjenDurumu: '',
    );
    final extra1 = [ExtraModel(ad: 'Limon', fiyat: 5.0)];
    final extra2 = [ExtraModel(ad: 'Acı Sos', fiyat: 10.0)];

    cartController.addToCart(food, quantity: 2, selectedExtras: extra1);
    cartController.addToCart(food, quantity: 1, selectedExtras: extra2);

    expect(cartController.totalItemCount, 3);
    // Attempting to increment when total across variants is already 3 (= porsiyonStok) must not exceed stock
    cartController.incrementItem(cartController.items.first.id);
    expect(cartController.totalItemCount, 3);
  });
}


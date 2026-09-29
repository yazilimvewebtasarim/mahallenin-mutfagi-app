import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sandbox_app/core/routes/app_pages.dart';
import 'package:sandbox_app/core/routes/app_routes.dart';
import 'package:sandbox_app/core/theme/theme.dart';
import 'package:sandbox_app/data/models/food_model.dart';
import 'package:sandbox_app/data/services/chef_service.dart';
import 'package:sandbox_app/features/chef/controllers/chef_controller.dart';
import 'package:sandbox_app/features/chef/views/chef_add_food_view.dart';
import 'package:sandbox_app/features/chef/views/chef_menu_view.dart';
import 'package:sandbox_app/main.dart';

class MockChefService extends ChefService {
  final List<FoodModel> items;

  MockChefService({List<FoodModel>? initialItems})
      : items = initialItems ?? [];

  @override
  Future<List<FoodModel>> getFoods({String? chefId}) async {
    return List<FoodModel>.from(items);
  }

  @override
  Future<FoodModel> addFood(FoodModel food) async {
    final created = food.copyWith(id: 'mock_created_id');
    items.insert(0, created);
    return created;
  }

  @override
  Future<bool> deleteFood(String id) async {
    items.removeWhere((item) => item.id == id);
    return true;
  }

  @override
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return {
      "orderCount": 0,
      "paidOrderLimit": 10,
    };
  }

  @override
  Future<bool> notifyPayment({int rights = 10}) async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> initializeShopierCheckout({int rights = 10}) async {
    return {"success": true, "paymentPageUrl": "https://shopier.com"};
  }
}


void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('MyApp mounts and displays SplashView', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify initial splash content is rendered
    expect(find.text('Mahallenin Mutfağı'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);

    // Drain pending timers from SplashController
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('FoodModel serialization, deserialization, and copyWith test', () {
    final json = {
      'id': 'dish_101',
      'chefId': 'chef_abc',
      'isim': 'Kayseri Mantısı',
      'aciklama': 'Yoğurtlu ve naneli enfes mantı',
      'fiyat': 150.0,
      'porsiyon_stok': 20,
      'alerjen_durumu': 'Gluten, Süt Ürünü',
      'resim_url': 'https://example.com/manti.jpg',
      'createdAt': '2026-09-17T12:00:00Z',
    };

    final food = FoodModel.fromJson(json);
    expect(food.id, 'dish_101');
    expect(food.chefId, 'chef_abc');
    expect(food.isim, 'Kayseri Mantısı');
    expect(food.fiyat, 150.0);
    expect(food.porsiyonStok, 20);
    expect(food.alerjenDurumu, 'Gluten, Süt Ürünü');
    expect(food.resimUrl, 'https://example.com/manti.jpg');

    final serialized = food.toJson();
    expect(serialized['isim'], 'Kayseri Mantısı');
    expect(serialized['fiyat'], 150.0);
    expect(serialized['porsiyon_stok'], 20);
    expect(serialized['alerjen_durumu'], 'Gluten, Süt Ürünü');
    expect(serialized['resim_url'], 'https://example.com/manti.jpg');

    // Test fallback parsing keys
    final fallbackJson = {
      'name': 'Karnıyarık',
      'description': 'Patlıcan ve kıymalı',
      'price': 120,
      'stock': 15,
      'allergenInfo': 'Yok',
      'imageUrl': 'https://example.com/karniyarik.jpg',
    };
    final fallbackFood = FoodModel.fromJson(fallbackJson);
    expect(fallbackFood.isim, 'Karnıyarık');
    expect(fallbackFood.aciklama, 'Patlıcan ve kıymalı');
    expect(fallbackFood.fiyat, 120.0);
    expect(fallbackFood.porsiyonStok, 15);

    // Test copyWith
    final updatedFood = food.copyWith(
      fiyat: 175.0,
      porsiyonStok: 10,
    );
    expect(updatedFood.fiyat, 175.0);
    expect(updatedFood.porsiyonStok, 10);
    expect(updatedFood.isim, food.isim);
    expect(updatedFood.id, food.id);
  });

  test('ChefController input validators and clearForm test', () {
    final mockService = MockChefService();
    final controller = ChefController(chefService: mockService);

    // Name validation
    expect(controller.validateName(''), isNotNull);
    expect(controller.validateName('A'), isNotNull);
    expect(controller.validateName('Karnıyarık'), isNull);

    // Description validation
    expect(controller.validateDescription(''), isNotNull);
    expect(controller.validateDescription('Az'), isNotNull);
    expect(controller.validateDescription('Taze patlıcanlı fırın yemeği'), isNull);

    // Price validation
    expect(controller.validatePrice(''), isNotNull);
    expect(controller.validatePrice('0'), isNotNull);
    expect(controller.validatePrice('-10'), isNotNull);
    expect(controller.validatePrice('abc'), isNotNull);
    expect(controller.validatePrice('120'), isNull);
    expect(controller.validatePrice('120,50'), isNull);

    // Stock validation
    expect(controller.validateStock(''), isNotNull);
    expect(controller.validateStock('-5'), isNotNull);
    expect(controller.validateStock('abc'), isNotNull);
    expect(controller.validateStock('15'), isNull);

    // Form clear test
    controller.nameController.text = 'Sarma';
    controller.descriptionController.text = 'Zeytinyağlı yaprak sarma';
    controller.priceController.text = '90';
    controller.stockController.text = '25';
    controller.allergenController.text = 'Yok';
    controller.imageUrlController.text = 'https://example.com/sarma.jpg';

    controller.clearForm();
    expect(controller.nameController.text, isEmpty);
    expect(controller.descriptionController.text, isEmpty);
    expect(controller.priceController.text, isEmpty);
    expect(controller.stockController.text, isEmpty);
    expect(controller.allergenController.text, isEmpty);
    expect(controller.imageUrlController.text, isEmpty);

    controller.dispose();
  });

  test('AppPages contains all required GetX routes with bindings', () {
    final routeNames = AppPages.routes.map((p) => p.name).toList();

    expect(routeNames, contains(AppRoutes.splash));
    expect(routeNames, contains(AppRoutes.roleSelect));
    expect(routeNames, contains(AppRoutes.login));
    expect(routeNames, contains(AppRoutes.chefMenu));
    expect(routeNames, contains(AppRoutes.chefAddFood));

    expect(AppPages.initial, AppRoutes.splash);
  });

  testWidgets('ChefMenuView renders empty state and action button', (WidgetTester tester) async {
    final mockService = MockChefService(initialItems: []);
    final controller = Get.put(ChefController(chefService: mockService));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const ChefMenuView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aşçı Paneli — Menü'), findsOneWidget);
    expect(find.text('Menünüzde henüz yemek yok'), findsOneWidget);
    expect(find.text('Yeni Yemek Ekle'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('ChefMenuView renders food card when dishes exist', (WidgetTester tester) async {
    final testDish = const FoodModel(
      id: 'dish_001',
      isim: 'İçli Köfte',
      aciklama: 'Cevizli ve kıymalı çıtır içli köfte',
      fiyat: 80.0,
      porsiyonStok: 12,
      alerjenDurumu: 'Gluten, Ceviz',
      resimUrl: '',
    );

    final mockService = MockChefService(initialItems: [testDish]);
    final controller = Get.put(ChefController(chefService: mockService));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const ChefMenuView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İçli Köfte'), findsOneWidget);
    expect(find.text('Cevizli ve kıymalı çıtır içli köfte'), findsOneWidget);
    expect(find.text('80.00 ₺'), findsOneWidget);
    expect(find.text('12 Porsiyon'), findsOneWidget);
    expect(find.text('Gluten, Ceviz'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('ChefAddFoodView renders form fields and validates inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockService = MockChefService();
    final controller = Get.put(ChefController(chefService: mockService));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const ChefAddFoodView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yeni Yemek Ekle'), findsOneWidget);
    expect(find.text('Yemek Detayları'), findsOneWidget);
    expect(find.text('Yemeği Menüye Ekle'), findsOneWidget);

    // Ensure button is visible and tap with empty form to trigger validation errors
    await tester.ensureVisible(find.text('Yemeği Menüye Ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yemeği Menüye Ekle'));
    await tester.pumpAndSettle();

    expect(find.text('Yemek adı zorunludur'), findsOneWidget);
    expect(find.text('Açıklama zorunludur'), findsOneWidget);
    expect(find.text('Fiyat zorunludur'), findsOneWidget);
    expect(find.text('Porsiyon stoğu zorunludur'), findsOneWidget);

    controller.dispose();
  });
}

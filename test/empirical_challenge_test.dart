import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:sandbox_app/core/constants/api_constants.dart';
import 'package:sandbox_app/core/theme/theme.dart';
import 'package:sandbox_app/data/models/food_model.dart';
import 'package:sandbox_app/data/services/chef_service.dart';
import 'package:sandbox_app/features/chef/controllers/chef_controller.dart';
import 'package:sandbox_app/features/chef/views/chef_add_food_view.dart';
import 'package:sandbox_app/features/chef/views/chef_menu_view.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Challenge 1: FoodModel Edge Cases & Serialization', () {
    test('Handles empty Map without throwing', () {
      final model = FoodModel.fromJson({});
      expect(model.id, isNull);
      expect(model.chefId, isNull);
      expect(model.isim, '');
      expect(model.aciklama, '');
      expect(model.fiyat, 0.0);
      expect(model.porsiyonStok, 0);
      expect(model.alerjenDurumu, '');
      expect(model.resimUrl, '');
      expect(model.createdAt, isNull);
    });

    test('Handles null explicitly for every nullable and defaultable field', () {
      final json = <String, dynamic>{
        'id': null,
        'chefId': null,
        'isim': null,
        'aciklama': null,
        'fiyat': null,
        'porsiyon_stok': null,
        'alerjen_durumu': null,
        'resim_url': null,
        'createdAt': null,
      };

      final model = FoodModel.fromJson(json);
      expect(model.id, isNull);
      expect(model.chefId, isNull);
      expect(model.isim, '');
      expect(model.aciklama, '');
      expect(model.fiyat, 0.0);
      expect(model.porsiyonStok, 0);
      expect(model.alerjenDurumu, '');
      expect(model.resimUrl, '');
      expect(model.createdAt, isNull);
    });

    test('Handles numeric type variations: int as fiyat, double as porsiyonStok', () {
      final json = <String, dynamic>{
        'isim': 'Lahmacun',
        'fiyat': 75, // int instead of double
        'porsiyon_stok': 25.0, // double instead of int
      };

      final model = FoodModel.fromJson(json);
      expect(model.fiyat, 75.0);
      expect(model.porsiyonStok, 25);
    });

    test('Handles zero values properly', () {
      final json = <String, dynamic>{
        'isim': 'Su',
        'fiyat': 0.0,
        'porsiyon_stok': 0,
      };

      final model = FoodModel.fromJson(json);
      expect(model.fiyat, 0.0);
      expect(model.porsiyonStok, 0);
    });

    test('Handles alternative English key mappings', () {
      final json = <String, dynamic>{
        'name': 'Kelle Paça',
        'description': 'Sarımsaklı ve sirkeli',
        'price': 180.5,
        'stock': 12,
        'allergenInfo': 'Sarımsak',
        'imageUrl': 'https://example.com/soup.jpg',
      };

      final model = FoodModel.fromJson(json);
      expect(model.isim, 'Kelle Paça');
      expect(model.aciklama, 'Sarımsaklı ve sirkeli');
      expect(model.fiyat, 180.5);
      expect(model.porsiyonStok, 12);
      expect(model.alerjenDurumu, 'Sarımsak');
      expect(model.resimUrl, 'https://example.com/soup.jpg');
    });

    test('toJson produces clean map omitting nulls', () {
      const model = FoodModel(
        isim: 'Kuru Fasulye',
        aciklama: 'Etsiz tereyağlı',
        fiyat: 110.0,
        porsiyonStok: 14,
        alerjenDurumu: 'Süt ürünü',
        resimUrl: 'https://example.com/fasulye.jpg',
      );

      final map = model.toJson();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('chefId'), isFalse);
      expect(map.containsKey('createdAt'), isFalse);
      expect(map['isim'], 'Kuru Fasulye');
      expect(map['aciklama'], 'Etsiz tereyağlı');
      expect(map['fiyat'], 110.0);
      expect(map['porsiyon_stok'], 14);
    });

    test('toJson includes id, chefId, and createdAt when present', () {
      const model = FoodModel(
        id: 'doc_123',
        chefId: 'chef_99',
        isim: 'Pilav',
        aciklama: 'Şehriyeli',
        fiyat: 50.0,
        porsiyonStok: 30,
        alerjenDurumu: 'Gluten',
        resimUrl: '',
        createdAt: '2026-09-17T20:00:00Z',
      );

      final map = model.toJson();
      expect(map['id'], 'doc_123');
      expect(map['chefId'], 'chef_99');
      expect(map['createdAt'], '2026-09-17T20:00:00Z');
    });

    test('copyWith updates specified fields and preserves others', () {
      const original = FoodModel(
        id: 'orig_id',
        chefId: 'orig_chef',
        isim: 'Original Name',
        aciklama: 'Original Desc',
        fiyat: 100.0,
        porsiyonStok: 5,
        alerjenDurumu: 'None',
        resimUrl: 'https://example.com/pic.png',
        createdAt: '2026-01-01',
      );

      final updated = original.copyWith(
        isim: 'Updated Name',
        fiyat: 125.0,
      );

      expect(updated.id, 'orig_id');
      expect(updated.chefId, 'orig_chef');
      expect(updated.isim, 'Updated Name');
      expect(updated.aciklama, 'Original Desc');
      expect(updated.fiyat, 125.0);
      expect(updated.porsiyonStok, 5);
      expect(updated.alerjenDurumu, 'None');
      expect(updated.resimUrl, 'https://example.com/pic.png');
      expect(updated.createdAt, '2026-01-01');
    });
  });

  group('Challenge 2: ChefController Validator Edge Cases', () {
    late ChefController controller;

    setUp(() {
      controller = ChefController(chefService: ChefService(dio: Dio()));
    });

    tearDown(() {
      controller.dispose();
    });

    test('validateName boundary tests', () {
      // Null, empty, whitespace
      expect(controller.validateName(null), 'Yemek adı zorunludur');
      expect(controller.validateName(''), 'Yemek adı zorunludur');
      expect(controller.validateName('   '), 'Yemek adı zorunludur');
      expect(controller.validateName('\t\n'), 'Yemek adı zorunludur');

      // Length boundaries
      expect(controller.validateName('A'), 'Yemek adı en az 2 karakter olmalıdır');
      expect(controller.validateName(' A '), 'Yemek adı en az 2 karakter olmalıdır');
      expect(controller.validateName('Su'), isNull); // 2 characters
      expect(controller.validateName('Et'), isNull);

      // Turkish characters & emojis
      expect(controller.validateName('Çiğ Köfte'), isNull);
      expect(controller.validateName('İskender'), isNull);
      expect(controller.validateName('Şöbiyet'), isNull);
      expect(controller.validateName('🍲 Çorba'), isNull);

      // Long strings
      final longName = 'A' * 255;
      expect(controller.validateName(longName), isNull);
    });

    test('validateDescription boundary tests', () {
      // Null, empty, whitespace
      expect(controller.validateDescription(null), 'Açıklama zorunludur');
      expect(controller.validateDescription(''), 'Açıklama zorunludur');
      expect(controller.validateDescription('   '), 'Açıklama zorunludur');

      // Length boundaries (< 5 characters)
      expect(controller.validateDescription('1234'), 'Açıklama en az 5 karakter olmalıdır');
      expect(controller.validateDescription('  ab  '), 'Açıklama en az 5 karakter olmalıdır');
      expect(controller.validateDescription('12345'), isNull); // exactly 5 characters
      expect(controller.validateDescription('Nefis'), isNull);

      // Multi-line and special chars
      expect(
        controller.validateDescription('Bol cevizli\nve tereyağlı ev baklavası'),
        isNull,
      );
    });

    test('validatePrice boundary tests', () {
      // Null, empty, whitespace
      expect(controller.validatePrice(null), 'Fiyat zorunludur');
      expect(controller.validatePrice(''), 'Fiyat zorunludur');
      expect(controller.validatePrice('   '), 'Fiyat zorunludur');

      // Zero & negative
      expect(controller.validatePrice('0'), contains('0\'dan büyük'));
      expect(controller.validatePrice('0.0'), contains('0\'dan büyük'));
      expect(controller.validatePrice('0,00'), contains('0\'dan büyük'));
      expect(controller.validatePrice('-1'), contains('0\'dan büyük'));
      expect(controller.validatePrice('-10.50'), contains('0\'dan büyük'));

      // Non-numeric
      expect(controller.validatePrice('abc'), contains('0\'dan büyük'));
      expect(controller.validatePrice('12..34'), contains('0\'dan büyük'));
      expect(controller.validatePrice('12,34,56'), contains('0\'dan büyük'));

      // Valid numbers
      expect(controller.validatePrice('0.01'), isNull);
      expect(controller.validatePrice('0,01'), isNull);
      expect(controller.validatePrice('150'), isNull);
      expect(controller.validatePrice('150.50'), isNull);
      expect(controller.validatePrice('150,75'), isNull);
      expect(controller.validatePrice('  99.90  '), isNull);
    });

    test('validateStock boundary tests', () {
      // Null, empty, whitespace
      expect(controller.validateStock(null), 'Porsiyon stoğu zorunludur');
      expect(controller.validateStock(''), 'Porsiyon stoğu zorunludur');
      expect(controller.validateStock('   '), 'Porsiyon stoğu zorunludur');

      // Negative & non-integers
      expect(controller.validateStock('-1'), contains('Geçerli bir porsiyon adedi giriniz'));
      expect(controller.validateStock('abc'), contains('Geçerli bir porsiyon adedi giriniz'));
      expect(controller.validateStock('5.5'), contains('Geçerli bir porsiyon adedi giriniz'));
      expect(controller.validateStock('5,5'), contains('Geçerli bir porsiyon adedi giriniz'));

      // Zero is valid (e.g. sold out dish registered in advance)
      expect(controller.validateStock('0'), isNull);

      // Positive integers
      expect(controller.validateStock('1'), isNull);
      expect(controller.validateStock('50'), isNull);
      expect(controller.validateStock('  20  '), isNull);
    });
  });

  group('Challenge 3: ChefService & Dio Integration Contract', () {
    test('ApiConstants provides valid base URL and endpoint', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.baseUrl, startsWith('http'));
      expect(ApiConstants.baseUrl, endsWith('/api/v1'));
      expect(ApiConstants.chefFoodsEndpoint, '/chef/foods');
    });

    test('ChefService.getFoods successfully parses { foods: [...] }', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'foods': [
                    {
                      'id': 'f1',
                      'isim': 'Mercimek Çorbası',
                      'aciklama': 'Sıcak ve leziz',
                      'fiyat': 60,
                      'porsiyon_stok': 20,
                      'alerjen_durumu': 'Yok',
                      'resim_url': '',
                    },
                    {
                      'id': 'f2',
                      'isim': 'Ezogelin',
                      'aciklama': 'Baharatlı',
                      'fiyat': 65.5,
                      'porsiyon_stok': 15,
                      'alerjen_durumu': 'Gluten',
                      'resim_url': '',
                    }
                  ]
                },
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      final result = await service.getFoods();

      expect(result.length, 2);
      expect(result[0].id, 'f1');
      expect(result[0].isim, 'Mercimek Çorbası');
      expect(result[0].fiyat, 60.0);
      expect(result[1].id, 'f2');
      expect(result[1].fiyat, 65.5);
    });

    test('ChefService.getFoods passes chefId queryParameter', () async {
      Map<String, dynamic>? capturedQuery;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedQuery = options.queryParameters;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'foods': []},
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      await service.getFoods(chefId: 'chef_test_42');

      expect(capturedQuery, isNotNull);
      expect(capturedQuery!['chefId'], 'chef_test_42');
    });

    test('ChefService.addFood serializes body and parses { food: {...} } response', () async {
      dynamic capturedBody;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedBody = options.data;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'message': 'Yemek başarıyla eklendi',
                  'id': 'doc_generated_777',
                  'food': {
                    'id': 'doc_generated_777',
                    'isim': options.data['isim'],
                    'aciklama': options.data['aciklama'],
                    'fiyat': options.data['fiyat'],
                    'porsiyon_stok': options.data['porsiyon_stok'],
                    'alerjen_durumu': options.data['alerjen_durumu'],
                    'resim_url': options.data['resim_url'],
                  }
                },
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      const newDish = FoodModel(
        isim: 'Ali Nazik',
        aciklama: 'Köz patlıcan ve yoğurt yatağında kuşbaşı et',
        fiyat: 220.0,
        porsiyonStok: 8,
        alerjenDurumu: 'Süt Ürünü',
        resimUrl: 'https://example.com/alinazik.jpg',
      );

      final created = await service.addFood(newDish);

      expect(capturedBody, isNotNull);
      expect(capturedBody['isim'], 'Ali Nazik');
      expect(capturedBody['fiyat'], 220.0);
      expect(capturedBody['porsiyon_stok'], 8);

      expect(created.id, 'doc_generated_777');
      expect(created.isim, 'Ali Nazik');
      expect(created.fiyat, 220.0);
    });

    test('ChefService.deleteFood sends DELETE to /chef/foods/:id', () async {
      String? capturedPath;
      String? capturedMethod;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedPath = options.path;
            capturedMethod = options.method;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'message': 'Yemek başarıyla silindi'},
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      final success = await service.deleteFood('dish_delete_99');

      expect(success, isTrue);
      expect(capturedMethod, 'DELETE');
      expect(capturedPath, '/chef/foods/dish_delete_99');
    });

    test('ChefService surfaces error message on DioException 400', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {'error': 'Yemek ismi (isim) zorunludur'},
                ),
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      const dish = FoodModel(
        isim: '',
        aciklama: 'test',
        fiyat: 50.0,
        porsiyonStok: 1,
        alerjenDurumu: '',
        resimUrl: '',
      );

      expect(
        () => service.addFood(dish),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains('Yemek ismi (isim) zorunludur')),
        ),
      );
    });
  });

  group('Challenge 4: UI & Controller Lifecycle Stress', () {
    testWidgets('ChefController manages loading and error state properly', (WidgetTester tester) async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'error': 'Sunucu hatası oluştu'},
                ),
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      final controller = Get.put(ChefController(chefService: service));

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChefMenuView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.errorMessage.value, contains('Sunucu hatası oluştu'));
      expect(find.text('Menü yüklenirken bir hata oluştu'), findsOneWidget);
      expect(find.text('Tekrar Dene'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('ChefAddFoodView submission handles whitespace trimming and default values', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      FoodModel? submittedDish;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            submittedDish = FoodModel.fromJson(options.data);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'message': 'Success',
                  'id': 'new_dish_id',
                  'food': options.data,
                },
              ),
            );
          },
        ),
      );

      final service = ChefService(dio: dio);
      final controller = Get.put(ChefController(chefService: service));

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const ChefAddFoodView(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter data with extra whitespace, comma in price, leave allergen and imageUrl empty
      controller.nameController.text = '  Fırın Sütlaç  ';
      controller.descriptionController.text = '  Fırınlanmış enfes pirinç tatlısı  ';
      controller.priceController.text = ' 85,50 ';
      controller.stockController.text = ' 20 ';
      controller.allergenController.text = ''; // empty -> should default to 'Belirtilmemiş'
      controller.imageUrlController.text = ''; // empty -> should default to unsplash fallback

      await tester.ensureVisible(find.text('Yemeği Menüye Ekle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yemeği Menüye Ekle'));
      await tester.pumpAndSettle();
      // Drain Get.snackbar timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(submittedDish, isNotNull);
      expect(submittedDish!.isim, 'Fırın Sütlaç');
      expect(submittedDish!.aciklama, 'Fırınlanmış enfes pirinç tatlısı');
      expect(submittedDish!.fiyat, 85.50);
      expect(submittedDish!.porsiyonStok, 20);
      expect(submittedDish!.alerjenDurumu, 'Belirtilmemiş');
      expect(submittedDish!.resimUrl, startsWith('https://images.unsplash.com'));

      controller.dispose();
    });
  });
}

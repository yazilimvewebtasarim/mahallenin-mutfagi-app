import 'food_model.dart';

class CartItemModel {
  final String id;
  final FoodModel food;
  final int quantity;
  final String? note;
  final List<ExtraModel> selectedExtras;

  const CartItemModel({
    required this.id,
    required this.food,
    this.quantity = 1,
    this.note,
    this.selectedExtras = const [],
  });

  double get itemTotal {
    double extrasTotal = selectedExtras.fold(0.0, (sum, extra) => sum + extra.fiyat);
    return (food.fiyat + extrasTotal) * quantity;
  }

  CartItemModel copyWith({
    String? id,
    FoodModel? food,
    int? quantity,
    String? note,
    List<ExtraModel>? selectedExtras,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      selectedExtras: selectedExtras ?? this.selectedExtras,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'quantity': quantity,
      'selectedExtras': selectedExtras.map((e) => e.toJson()).toList(),
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawExtras = (json['selectedExtras'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((e) => ExtraModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    FoodModel parsedFood;
    if (json['food'] is Map) {
      parsedFood = FoodModel.fromJson(Map<String, dynamic>.from(json['food'] as Map));
    } else {
      final double extrasSum = rawExtras.fold(0.0, (sum, ex) => sum + ex.fiyat);
      final double unitPrice = (json['price'] ?? json['fiyat'] ?? 0).toDouble();
      final double baseFoodPrice = (unitPrice - extrasSum) > 0 ? (unitPrice - extrasSum) : unitPrice;
      parsedFood = FoodModel(
        id: (json['foodId'] ?? json['id'] ?? '').toString(),
        chefId: json['chefId']?.toString(),
        isim: (json['isim'] ?? json['name'] ?? 'Ev Yemeği').toString(),
        aciklama: (json['aciklama'] ?? '').toString(),
        fiyat: baseFoodPrice,
        porsiyonStok: (json['porsiyon_stok'] as num?)?.toInt() ?? 1,
        alerjenDurumu: (json['alerjen_durumu'] ?? '').toString(),
        resimUrl: (json['resim_url'] ?? '').toString(),
      );
    }

    return CartItemModel(
      id: (json['id'] ?? json['foodId'] ?? '').toString(),
      food: parsedFood,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
      selectedExtras: rawExtras,
    );
  }
}

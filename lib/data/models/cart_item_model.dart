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
    return CartItemModel(
      id: json['id'] as String? ?? '',
      food: FoodModel.fromJson(json['food'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
      selectedExtras: (json['selectedExtras'] as List<dynamic>?)?.map((e) => ExtraModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

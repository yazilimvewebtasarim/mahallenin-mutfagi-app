import 'cart_item_model.dart';

class CartSummaryModel {
  final List<CartItemModel> items;
  final String? chefId;
  final String? chefName;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;

  const CartSummaryModel({
    required this.items,
    this.chefId,
    this.chefName,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CartSummaryModel(
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      chefId: json['chefId'] as String?,
      chefName: json['chefName'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      if (chefId != null) 'chefId': chefId,
      if (chefName != null) 'chefName': chefName,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
    };
  }
}

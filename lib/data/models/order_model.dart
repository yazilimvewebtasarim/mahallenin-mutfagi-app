import 'cart_item_model.dart';

class OrderModel {
  final String? id;
  final String customerId;
  final String chefId;
  final List<CartItemModel> items;
  final double totalAmount;
  final double? subtotal;
  final double? deliveryFee;
  final String status;
  final String? deliveryAddress;
  final String? customerName;
  final String? createdAt;

  const OrderModel({
    this.id,
    required this.customerId,
    required this.chefId,
    required this.items,
    required this.totalAmount,
    this.subtotal,
    this.deliveryFee,
    this.status = 'pending',
    this.deliveryAddress,
    this.customerName,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String?,
      customerId: json['customerId'] as String? ?? '',
      chefId: json['chefId'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      deliveryAddress: json['deliveryAddress'] as String?,
      customerName: json['customerName'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'chefId': chefId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      if (subtotal != null) 'subtotal': subtotal,
      if (deliveryFee != null) 'deliveryFee': deliveryFee,
      'status': status,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (customerName != null) 'customerName': customerName,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? chefId,
    List<CartItemModel>? items,
    double? totalAmount,
    double? subtotal,
    double? deliveryFee,
    String? status,
    String? deliveryAddress,
    String? customerName,
    String? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      chefId: chefId ?? this.chefId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

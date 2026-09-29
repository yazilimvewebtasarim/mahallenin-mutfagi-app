class BidModel {
  final String chefId;
  final String chefName;
  final double price;
  final String note;

  BidModel({
    required this.chefId,
    required this.chefName,
    required this.price,
    required this.note,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      chefId: json['chefId'] ?? '',
      chefName: json['chefName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      note: json['note'] ?? '',
    );
  }
}

class CustomRequestModel {
  final String id;
  final String customerId;
  final String title;
  final String description;
  final double? budget;
  final String status; // open, accepted, completed
  final List<BidModel> bids;
  final String? targetChefId;

  CustomRequestModel({
    required this.id,
    required this.customerId,
    required this.title,
    required this.description,
    this.budget,
    required this.status,
    required this.bids,
    this.targetChefId,
  });

  factory CustomRequestModel.fromJson(Map<String, dynamic> json) {
    return CustomRequestModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget']?.toDouble(),
      status: json['status'] ?? 'open',
      targetChefId: json['targetChefId'],
      bids: (json['bids'] as List?)?.map((e) => BidModel.fromJson(e)).toList() ?? [],
    );
  }
}

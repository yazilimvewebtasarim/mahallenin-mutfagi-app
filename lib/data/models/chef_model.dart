class ChefModel {
  final String id;
  final String isimSoyad;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final bool hijyenBelgesi;
  final String? mutfakResmiUrl;

  ChefModel({
    required this.id,
    required this.isimSoyad,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
    this.hijyenBelgesi = false,
    this.mutfakResmiUrl,
  });

  factory ChefModel.fromJson(Map<String, dynamic> json) {
    return ChefModel(
      id: json['id'] ?? '',
      isimSoyad: json['isim_soyad'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'],
      hijyenBelgesi: json['hijyenBelgesi'] == true,
      mutfakResmiUrl: json['mutfakResmiUrl'],
    );
  }
}

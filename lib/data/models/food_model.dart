class ExtraModel {
  final String ad;
  final double fiyat;

  ExtraModel({required this.ad, required this.fiyat});

  factory ExtraModel.fromJson(Map<String, dynamic> json) {
    return ExtraModel(
      ad: json['ad'] as String? ?? '',
      fiyat: (json['fiyat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'ad': ad,
        'fiyat': fiyat,
      };
}

class FoodModel {
  final String? id;
  final String? chefId;
  final String isim;
  final String aciklama;
  final double fiyat;
  final int porsiyonStok;
  final String alerjenDurumu;
  final String resimUrl;
  final List<ExtraModel> ekstralar;
  final String? createdAt;

  const FoodModel({
    this.id,
    this.chefId,
    required this.isim,
    required this.aciklama,
    required this.fiyat,
    required this.porsiyonStok,
    required this.alerjenDurumu,
    required this.resimUrl,
    this.ekstralar = const [],
    this.createdAt,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String?,
      chefId: json['chefId'] as String?,
      isim: json['isim'] as String? ?? json['name'] as String? ?? '',
      aciklama: json['aciklama'] as String? ?? json['description'] as String? ?? '',
      fiyat: (json['fiyat'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      porsiyonStok: (json['porsiyon_stok'] as num?)?.toInt() ?? (json['stock'] as num?)?.toInt() ?? 0,
      alerjenDurumu: json['alerjen_durumu'] as String? ?? json['allergenInfo'] as String? ?? '',
      resimUrl: json['resim_url'] as String? ?? json['imageUrl'] as String? ?? '',
      ekstralar: (json['ekstralar'] as List<dynamic>?)?.map((e) => ExtraModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (chefId != null) 'chefId': chefId,
      'isim': isim,
      'aciklama': aciklama,
      'fiyat': fiyat,
      'porsiyon_stok': porsiyonStok,
      'alerjen_durumu': alerjenDurumu,
      'resim_url': resimUrl,
      'ekstralar': ekstralar.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  FoodModel copyWith({
    String? id,
    String? chefId,
    String? isim,
    String? aciklama,
    double? fiyat,
    int? porsiyonStok,
    String? alerjenDurumu,
    String? resimUrl,
    List<ExtraModel>? ekstralar,
    String? createdAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      chefId: chefId ?? this.chefId,
      isim: isim ?? this.isim,
      aciklama: aciklama ?? this.aciklama,
      fiyat: fiyat ?? this.fiyat,
      porsiyonStok: porsiyonStok ?? this.porsiyonStok,
      alerjenDurumu: alerjenDurumu ?? this.alerjenDurumu,
      resimUrl: resimUrl ?? this.resimUrl,
      ekstralar: ekstralar ?? this.ekstralar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

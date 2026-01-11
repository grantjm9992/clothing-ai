class WardrobeItem {
  final String id;
  final String userId;
  final String? primaryPhotoId;
  final String category;
  final String? subCategory;
  final List<String> colors;
  final String? pattern;
  final String? material;
  final String? brand;
  final String? sizeLabel;
  final String? fit;
  final List<String> seasonTags;
  final int formality;
  final List<String> styleTags;
  final bool isActive;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  WardrobeItem({
    required this.id,
    required this.userId,
    this.primaryPhotoId,
    required this.category,
    this.subCategory,
    this.colors = const [],
    this.pattern,
    this.material,
    this.brand,
    this.sizeLabel,
    this.fit,
    this.seasonTags = const [],
    this.formality = 5,
    this.styleTags = const [],
    this.isActive = true,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'],
      userId: json['user_id'],
      primaryPhotoId: json['primary_photo_id'],
      category: json['category'],
      subCategory: json['sub_category'],
      colors: List<String>.from(json['colors'] ?? []),
      pattern: json['pattern'],
      material: json['material'],
      brand: json['brand'],
      sizeLabel: json['size_label'],
      fit: json['fit'],
      seasonTags: List<String>.from(json['season_tags'] ?? []),
      formality: json['formality'] ?? 5,
      styleTags: List<String>.from(json['style_tags'] ?? []),
      isActive: json['is_active'] ?? true,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'primary_photo_id': primaryPhotoId,
      'category': category,
      'sub_category': subCategory,
      'colors': colors,
      'pattern': pattern,
      'material': material,
      'brand': brand,
      'size_label': sizeLabel,
      'fit': fit,
      'season_tags': seasonTags,
      'formality': formality,
      'style_tags': styleTags,
      'is_active': isActive,
      'status': status,
    };
  }

  String get displayName {
    if (subCategory != null) return subCategory!;
    return category;
  }

  String get colorDisplay {
    if (colors.isEmpty) return 'No color';
    if (colors.length == 1) return colors[0];
    return colors.join(', ');
  }

  String get formalityLabel {
    if (formality <= 2) return 'Very Casual';
    if (formality <= 4) return 'Casual';
    if (formality <= 6) return 'Smart Casual';
    if (formality <= 8) return 'Formal';
    return 'Very Formal';
  }
}

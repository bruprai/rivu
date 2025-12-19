class StoreModel {
  final String id;
  final String userId;
  final String defaultCategoryId;
  final String name;
  final int usageCount;
  final DateTime createdAt;

  StoreModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.usageCount,
    required this.createdAt,
    required this.defaultCategoryId,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      defaultCategoryId: json['default_category_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'default_category_id': defaultCategoryId,
      'name': name,
      'usage_count': usageCount,
    };
  }
}

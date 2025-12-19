class TransactionModel {
  final String? id;
  final String userId;
  final String? accountId;
  final String categoryId;
  final String storeId;
  final double amount;
  final String? description;
  final DateTime? createdAt;
  final String? receiptUrl;

  TransactionModel({
    this.id,
    required this.userId,
    this.accountId,
    required this.categoryId,
    required this.storeId,
    required this.amount,
    this.description,
    this.createdAt,
    this.receiptUrl,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String,
      storeId: map['store_id'] ?? '',
      amount: map['amount'] as double,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      receiptUrl: map['receipt_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'store_id': storeId,
      'amount': amount,
      'description': description,
      'created_at': createdAt!.toIso8601String(),
      'receipt_url': receiptUrl,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    String? storeId,
    double? amount,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    String? receiptUrl,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,

      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      storeId: storeId ?? this.storeId,
    );
  }
}

class AccountModel {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String type;
  final String currency;

  AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.type,
    required this.currency,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'checking',
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'type': type,
      'currency': currency,
    };
  }
}

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String type;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'expense',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'name': name, 'type': type};
  }
}

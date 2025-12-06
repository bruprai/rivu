// lib/models/transaction.dart
class TransactionModel {
  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
    this.receiptUrl,
  });

  /// Create from Supabase row (Map)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      receiptUrl: map['receipt_url'] as String?,
    );
  }

  /// Convert to Map for inserts/updates
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'receipt_url': receiptUrl,
    };
  }

  /// Copy with changes (immutable updates)
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
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
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}

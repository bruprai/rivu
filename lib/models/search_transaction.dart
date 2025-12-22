import 'package:rivu/models/transaction.dart';

class SearchTransactionModel extends TransactionModel {
  final String? storeName;
  final String? categoryName;
  final String? accountName;
  final double searchRank;

  SearchTransactionModel.fromMap(super.map)
    : storeName = map['store_name'],
      categoryName = map['category_name'],
      accountName = map['account_name'],
      searchRank = (map['search_rank'] ?? 0).toDouble(),
      super.fromMap();

  bool get isHighRank => searchRank > 0.1;
  bool matchesStore(String filter) =>
      storeName?.toLowerCase().contains(filter.toLowerCase()) ?? false;
  bool matchesCategory(String filter) =>
      categoryName?.toLowerCase().contains(filter.toLowerCase()) ?? false;
  bool matchesAccount(String filter) =>
      accountName?.toLowerCase().contains(filter.toLowerCase()) ?? false;
}

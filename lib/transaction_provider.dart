import 'dart:io';

import 'package:rivu/models/search_transaction.dart';
import 'package:rivu/models/store.dart';
import 'package:rivu/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider extends ChangeNotifier {
  String? _currentUserId;
  final SupabaseClient supabase = Supabase.instance.client;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  List<AccountModel> _accounts = [];
  List<AccountModel> get accounts => _accounts;
  bool _isLoadingAccounts = false;
  bool get isLoadingAccounts => _isLoadingAccounts;
  String? _errorMessageAccounts;
  String? get errorMessageAccounts => _errorMessageAccounts;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;
  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;
  String? _errorMessageCategories;
  String? get errorMessageCategories => _errorMessageCategories;

  List<StoreModel> _stores = [];
  List<StoreModel> get stores => _stores;
  bool _isLoadingStores = false;
  bool get isLoadingStores => _isLoadingStores;
  String? _errorMessageStores;
  String? get errorMessageStores => _errorMessageStores;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  StoreModel? _selectedStore;
  StoreModel? get selectedStore => _selectedStore;

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  void setSelectedCategory(CategoryModel category) {
    _selectedCategory = categories.firstWhere(
      (cat) => cat.name.toLowerCase() == category.name.toLowerCase(),
    );
  }

  void setDefaultSelectedCategory() {
    _selectedCategory = categories.firstWhere(
      (categiry) => categiry.id == _selectedStore!.defaultCategoryId,
    );
  }

  void setDefaultSelectedStore() {
    _selectedStore = stores.isEmpty
        ? null
        : stores.reduce(
            (currentHighest, nextStore) =>
                nextStore.usageCount! > currentHighest.usageCount!
                ? nextStore
                : currentHighest,
          );
  }

  void setSelectedStoreById(String id) {
    _selectedStore = stores.firstWhere((store) => store.id == id);
  }

  String? get currentUserId => _currentUserId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SearchTransactionModel> _searchResults = [];
  String? _storeFilter;
  String? _categoryFilter;
  double _minRank = 0.0;

  List<SearchTransactionModel> get filteredSearchResults {
    return _searchResults.where((tx) {
      return (tx.isHighRank || _minRank == 0) &&
          (_storeFilter == null || tx.matchesStore(_storeFilter!)) &&
          (_categoryFilter == null || tx.matchesCategory(_categoryFilter!));
    }).toList();
  }

  void setStoreFilter(String? store) {
    _storeFilter = store;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setMinRank(double rank) {
    _minRank = rank;
    notifyListeners();
  }

  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchStores(userId);
      await fetchAccounts();
      await fetchCategories();
      await fetchTransactions();

      _errorMessage = null;
    } on PostgrestException catch (e) {
      _errorMessage = 'Database error: ${e.message}';
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('transactions')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      _transactions = data.map((row) => TransactionModel.fromMap(row)).toList();
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future searchTranasctions(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await supabase.rpc(
        'search_transactions',
        params: {'query_text': query},
      );
      _searchResults = data
          .map((row) => TransactionModel.fromMap(row))
          .toList();
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.from('transactions').insert(transaction.toJson());
      await fetchTransactions();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      debugPrint("addTransaction ${transaction.toJson()}");
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    } catch (_) {
      debugPrint("addTransaction ${transaction.toJson()}");
      _errorMessage = 'Failed to add transaction';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(String id, TransactionModel updated) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.from('transactions').update(updated.toJson()).eq('id', id);

      await fetchTransactions();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to update transaction';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.from('transactions').delete().eq('id', id);

      await fetchTransactions();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to delete transaction';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchStores(String userId) async {
    _isLoadingStores = true;
    _errorMessageStores = null;
    notifyListeners();

    try {
      final storesData = await supabase
          .from('stores')
          .select()
          .eq('user_id', userId)
          .order(
            'usage_count',
            ascending: false,
          ) // Primary Sort:  store with the highest usage_count will come first
          .order(
            'name',
          ); // Secondary Sort: name in ascending (alphabetical) order.
      // If two or more stores have the same usage_count, they will then be sorted alphabetically by their name.

      _stores = storesData.map((json) => StoreModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      _errorMessageStores = e.message;
    } catch (e) {
      _errorMessageStores = 'Failed to load stores';
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  Future<void> incrementStoreUsage(String storeId) async {
    _errorMessageStores = null;
    _isLoadingStores = true;
    notifyListeners();

    try {
      final store = _stores.firstWhere((s) => s.id == storeId);
      await supabase
          .from('stores')
          .update({'usage_count': store.usageCount! + 1})
          .eq('id', storeId);

      // Refresh list
      await fetchStores(currentUserId!);
    } on PostgrestException catch (e) {
      _errorMessageStores = e.message;
    } catch (e) {
      _errorMessageStores = 'Failed to update store usage';
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  Future<bool> addStore(String name) async {
    _errorMessageStores = null;
    _isLoadingStores = true;
    notifyListeners();

    try {
      await supabase.from('stores').insert({
        'user_id': currentUserId!,
        'name': name,
        'default_category_id': _selectedCategory!.id,
      });

      await fetchStores(currentUserId!);
      setDefaultSelectedStore();
      setDefaultSelectedCategory();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageStores = e.message;
    } catch (e) {
      _errorMessageStores = 'Failed to add store';
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteStore(String storeId) async {
    _errorMessageStores = null;
    _isLoadingStores = true;
    notifyListeners();

    try {
      await supabase.from('stores').delete().eq('id', storeId);
      await fetchStores(currentUserId!);
      setDefaultSelectedStore();
      setDefaultSelectedCategory();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageStores = e.message;
    } catch (e) {
      _errorMessageStores = 'Failed to delete store';
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
    return false;
  }

  Future<String> fetchStoreLogo(String name) async {
    final client = HttpClient();
    _errorMessageStores = null;
    _isLoadingStores = true;
    notifyListeners();

    try {
      var url = Uri.https(
        "https://cdn.brandfetch.io/$name.com?c=1idpjjuA4YXBRQcVZ5n",
      );
      var response = await client.getUrl(url);
      print("Resposne $response");
      return "";
    } on PostgrestException catch (e) {
      _errorMessageStores = e.message;
    } catch (e) {
      _errorMessageStores = 'Failed to fetch store logo';
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
    return "";
  }

  Future<void> fetchAccounts() async {
    if (_currentUserId == null) {
      _errorMessageAccounts = 'User not logged in';
      _isLoadingAccounts = false;
      notifyListeners();
      return;
    }

    _isLoadingAccounts = true;
    _errorMessageAccounts = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('accounts')
          .select()
          .eq('user_id', _currentUserId!)
          .order('name', ascending: true);
      _accounts = data.map((json) => AccountModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      _errorMessageAccounts = e.message;
    } catch (e) {
      _errorMessageAccounts = 'Failed to load accounts';
    } finally {
      _isLoadingAccounts = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount(String name) async {
    if (_currentUserId == null) return false;

    _isLoadingAccounts = true;
    _errorMessageAccounts = null;
    notifyListeners();

    try {
      await supabase.from('accounts').insert({
        'user_id': _currentUserId!,
        'name': name,
        'balance': 0.0,
        'type': 'checking',
        'currency': 'CAD',
      });
      await fetchAccounts();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageAccounts = 'Account error $e}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessageAccounts = 'Failed to add account';
      notifyListeners();
      return false;
    } finally {
      _isLoadingAccounts = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    if (_currentUserId == null) return false;

    _isLoadingAccounts = true;
    _errorMessageAccounts = null;
    notifyListeners();

    try {
      await supabase.from('accounts').delete().eq('id', accountId);
      await fetchAccounts();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageAccounts = 'Failed to delete account';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessageAccounts = 'Connection error';
      notifyListeners();
      return false;
    } finally {
      _isLoadingAccounts = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    if (_currentUserId == null) {
      _errorMessageCategories = 'User not logged in';
      _isLoadingCategories = false;
      notifyListeners();
      return;
    }

    _isLoadingCategories = true;
    _errorMessageCategories = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('categories')
          .select()
          .eq('user_id', _currentUserId!)
          .order('name');
      _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      _errorMessageCategories = e.message;
    } catch (e) {
      _errorMessageCategories = 'Failed to load categories';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name) async {
    if (_currentUserId == null) return false;

    _isLoadingCategories = true;
    _errorMessageCategories = null;
    notifyListeners();

    try {
      await supabase.from('categories').insert({
        'user_id': _currentUserId!,
        'name': name,
        'type': 'expense',
      });
      await fetchCategories();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageCategories = 'Category "${name}" already exists';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessageCategories = 'Failed to add category';
      notifyListeners();
      return false;
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    if (_currentUserId == null) return false;

    _isLoadingCategories = true;
    _errorMessageCategories = null;
    notifyListeners();

    try {
      await supabase.from('categories').delete().eq('id', categoryId);
      await fetchCategories();
      return true;
    } on PostgrestException catch (e) {
      _errorMessageCategories = 'Failed to delete category';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessageCategories = 'Connection error';
      notifyListeners();
      return false;
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }
}

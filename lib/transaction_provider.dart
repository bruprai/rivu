import 'package:extra/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('transactions')
          .select()
          .order('date', ascending: false);

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

  Future<bool> addTransaction(TransactionModel transaction) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.from('transactions').insert(transaction.toMap());
      await fetchTransactions();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to add transaction';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(String id, TransactionModel updated) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.from('transactions').update(updated.toMap()).eq('id', id);

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
}

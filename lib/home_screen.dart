import 'package:rivu/core/app_constants.dart';
import 'package:rivu/core/colors.dart';
import 'package:rivu/models/store.dart';
import 'package:rivu/models/transaction.dart';
import 'package:rivu/theme_provider.dart';
import 'package:rivu/widgets/manage_items_dialog.dart';
import 'package:rivu/widgets/transaction_form.dart';
import 'package:rivu/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'transaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDelayed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      Future.delayed(Duration(milliseconds: 2500), () {
        setState(() {
          isDelayed = false;
        });
      });
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      txProvider.setCurrentUser(authProvider.user!.id);
      await txProvider.fetchUserData(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, TransactionProvider, ThemeProvider>(
      builder: (context, authProvider, txProvider, themeProvider, child) {
        if (txProvider.isLoading || isDelayed) {
          return Scaffold(
            body: Center(child: Image.asset('assets/rivu-no-background.gif')),
          );
        }

        if (txProvider.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Extra')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${txProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Welcome, ${authProvider.user?.email!.split("@")[0] ?? 'Guest'}',
            ),
            actions: [
              const ThemeToggle(),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => authProvider.signOut(),
              ),
            ],
          ),
          body: _buildTransactionsList(txProvider),
          floatingActionButton: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: "add_tx",
                    onPressed: () => _showAddTransactionDialog(context),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "manage_accounts",
                    mini: true,
                    onPressed: () => _showManageBottomSheet('Accounts'),
                    child: const Icon(Icons.account_balance_wallet),
                  ),
                  FloatingActionButton(
                    heroTag: "manage_categories",
                    mini: true,
                    onPressed: () => _showManageBottomSheet('Categories'),
                    child: const Icon(Icons.category),
                  ),
                  FloatingActionButton(
                    heroTag: "manage_stores",
                    mini: true,
                    onPressed: () => _showManageBottomSheet('Stores'),
                    child: const Icon(Icons.store),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(TransactionProvider txProvider) {
    if (txProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (txProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(txProvider.errorMessage!),
            ElevatedButton(
              onPressed: () => txProvider.fetchTransactions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (txProvider.transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transactions yet'),
            Text(
              'Tap + to add your first one!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: txProvider.transactions.length,
      itemBuilder: (context, index) {
        final tx = txProvider.transactions[index];
        return ListTile(
          leading: Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceDark,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(tx.createdAt!).split(' ').first,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  _formatDate(tx.createdAt!).split(' ').last.substring(0, 3),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          title: Text(tx.description ?? 'No description'),
          subtitle: Text(
            txProvider.categories
                .firstWhere((category) => category.id == tx.categoryId)
                .name,
          ),

          trailing: Text(
            _formatAmount(tx.amount),
            style: TextStyle(
              color: tx.amount >= 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppConstants.months[date.month - 1]}';
  }

  String _formatAmount(double amount) {
    return '${amount >= 0 ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}';
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => TransactionForm());
  }

  void _showManageBottomSheet<T>(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext content) {
        final height = MediaQuery.of(context).size.height * 0.5;
        return Container(
          height: height,
          padding: EdgeInsets.all(16),
          child: Consumer<TransactionProvider>(
            builder: (context, txProvider, child) {
              return ManageItemsDialog<T>(
                title: title,
                items: title == 'Stores'
                    ? List<T>.from(txProvider.stores as List<T>)
                    : title == 'Accounts'
                    ? List<T>.from(txProvider.accounts as List<T>)
                    : List<T>.from(txProvider.categories as List<T>),
                onDelete: (T item) async {
                  if (item is AccountModel) {
                    return await txProvider.deleteAccount(item.id);
                  } else if (item is CategoryModel) {
                    return await txProvider.deleteCategory(item.id);
                  } else if (item is StoreModel) {
                    return await txProvider.deleteStore(item.id);
                  }
                  return false;
                },
                onAdd: (String name) async {
                  switch (title) {
                    case 'Accounts':
                      return await txProvider.addAccount(name);
                    case 'Categories':
                      return await txProvider.addCategory(name);
                    case 'Stores':
                      return await txProvider.addStore(name);
                    default:
                      return false;
                  }
                },
                getName: (item) {
                  if (item is AccountModel) return item.name;
                  if (item is CategoryModel) return item.name;
                  if (item is StoreModel) return item.name;
                  return 'Unknown';
                },
              );
            },
          ),
        );
      },
    );
  }

  void _editTransaction(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (_) => TransactionForm(transaction: tx),
    );
  }
}

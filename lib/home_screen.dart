import 'package:extra/core/colors.dart';
import 'package:extra/models/transaction.dart';
import 'package:extra/widgets/gl_transaction_form.dart';
import 'package:extra/widgets/theme_toggle.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authProvider.user?.email ?? 'Guest'}'),
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: _buildTransactionsList(transactionProvider),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        child: Icon(Icons.add),
      ),
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
          title: Text(tx.description ?? 'No description'),
          subtitle: Text(_formatDate(tx.date)),
          trailing: Text(
            _formatAmount(tx.amount),
            style: TextStyle(
              color: tx.amount >= 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          //          trailing: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     if (tx.receiptUrl != null)
          //       ClipRRect(
          //         borderRadius: BorderRadius.circular(8),
          //         child: Image.network(
          //           tx.receiptUrl!,
          //           width: 40,
          //           height: 40,
          //           fit: BoxFit.cover,
          //           errorBuilder: (_, __, ___) => Icon(Icons.receipt, size: 20),
          //         ),
          //       ),
          //     // Edit/Delete buttons...
          //   ],
          // ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(double amount) {
    return '${amount >= 0 ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}';
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => GlassTransactionForm());
  }

  // Edit transaction
  void _editTransaction(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (_) => GlassTransactionForm(transaction: tx),
    );
  }
}

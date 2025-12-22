import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivu/models/store.dart';
import 'package:rivu/models/transaction.dart';
import 'package:rivu/transaction_provider.dart';
import 'package:rivu/widgets/manage_items_dialog.dart';

typedef AddCallback = Future<bool> Function(String name);
typedef DeleteCallback<T> = Future<bool> Function(T item);

Future<void> showManageBottomSheet({
  required BuildContext context,
  required String title, // 'Stores' | 'Accounts' | 'Categories'
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,

    builder: (bottomSheetContext) {
      final height = MediaQuery.of(bottomSheetContext).size.height * 0.5;

      return SizedBox(
        height: height,
        //  padding: const EdgeInsets.all(16),
        child: Consumer<TransactionProvider>(
          builder: (context, txProvider, child) {
            // Pick list based on title
            final items = switch (title) {
              'Stores' => txProvider.stores,
              'Accounts' => txProvider.accounts,
              'Categories' => txProvider.categories,
              _ => const [],
            };

            return ManageItemsDialog(
              title: title,
              items: items,
              getName: (item) {
                if (item is AccountModel) return item.name;
                if (item is CategoryModel) return item.name;
                if (item is StoreModel) return item.name;
                return 'Unknown';
              },
              onAdd: (String name) async {
                return switch (title) {
                  'Accounts' => await txProvider.addAccount(name),
                  'Categories' => await txProvider.addCategory(name),
                  'Stores' => await txProvider.addStore(name),
                  _ => false,
                };
              },
              onDelete: (item) async {
                if (item is AccountModel) {
                  return await txProvider.deleteAccount(item.id);
                }
                if (item is CategoryModel) {
                  return await txProvider.deleteCategory(item.id);
                }
                if (item is StoreModel) {
                  return await txProvider.deleteStore(item.id!);
                }
                return false;
              },
            );
          },
        ),
      );
    },
  );
}

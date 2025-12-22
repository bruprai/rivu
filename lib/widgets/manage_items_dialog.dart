// lib/widgets/manage_items_dialog.dart - ✅ Generic CRUD Dialog
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivu/core/app_constants.dart';
import 'package:rivu/core/colors.dart';
import 'package:rivu/models/store.dart';
import 'package:rivu/models/transaction.dart';
import 'package:rivu/transaction_provider.dart';

class ManageItemsDialog<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Future<bool> Function(T) onDelete;
  final Future<bool> Function(String) onAdd;
  final String Function(T) getName;

  const ManageItemsDialog({
    super.key,
    required this.title,
    required this.items,
    required this.onDelete,
    required this.onAdd,
    required this.getName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final themeContext = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(16),
      child: Consumer<TransactionProvider>(
        builder: (context, txProvider, _) {
          return Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              Row(
                spacing: 16,
                mainAxisSize: .min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText:
                                'Enter ${title.substring(0, title.length - 1)} Name',
                            labelStyle: AppConstants.labelBolder,
                          ),
                        ),
                        SizedBox(height: 8),
                        title.toLowerCase() != 'stores'
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: DropdownButtonFormField<CategoryModel>(
                                  initialValue: txProvider.categories[1],
                                  items: txProvider.categories
                                      .map(
                                        (category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (category) =>
                                      txProvider.setSelectedCategory(category!),
                                ),
                              ),
                      ],
                    ),
                  ),

                  Container(
                    margin: .only(left: 10, top: 10),

                    alignment: .center,
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: themeContext.focusColor,
                      borderRadius: .circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: themeContext.cardColor,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: IconButton(
                      icon: Icon(
                        Icons.check,
                        size: title.toLowerCase() != 'stores' ? 32 : 48,
                        color: AppColors.logo,
                      ),
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          var isDuplicateStore = txProvider.stores.firstWhere(
                            (store) =>
                                store.name.toLowerCase() ==
                                controller.text.toLowerCase(),
                            orElse: () => StoreModel(userId: '', name: ''),
                          );
                          if (isDuplicateStore.userId.isEmpty) {
                            await onAdd(controller.text);
                          }
                          controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  padding: .all(12),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: themeContext.highlightColor,
                          ),
                        ),
                        tileColor: themeContext.cardColor,

                        dense: true,
                        contentPadding: EdgeInsets.all(4),
                        titleAlignment: .center,
                        title: Text(
                          getName(item),
                          style: AppConstants.heading3,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.logo),
                          onPressed: () => onDelete(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

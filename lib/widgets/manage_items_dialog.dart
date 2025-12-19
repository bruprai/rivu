// lib/widgets/manage_items_dialog.dart - ✅ Generic CRUD Dialog
import 'package:flutter/material.dart';

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

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),

            // ✅ Add new
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Add $title',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await onAdd(controller.text);
                      controller.clear();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ List + Delete (sorted by usage)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(getName(item)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

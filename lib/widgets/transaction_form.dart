// lib/widgets/glass_transaction_form.dart
import 'dart:io';
import 'dart:ui';
import 'package:decimal/decimal.dart';
import 'package:rivu/auth_provider.dart';
import 'package:rivu/core/app_constants.dart';
import 'package:rivu/models/store.dart';
import 'package:rivu/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rivu/widgets/manage_items_bottomsheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import '../core/colors.dart';

// progressive‑disclosure UX patterns, where users can log quickly, then refine later
class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;
  final VoidCallback? onDismiss;

  const TransactionForm({super.key, this.transaction, this.onDismiss});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final TransactionProvider txProvider;
  late final AuthProvider authProvider;

  String? receiptUrl;
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    txProvider = context.read<TransactionProvider>();
    authProvider = context.read<AuthProvider>();
    _amountController.text = widget.transaction?.amount.abs().toString() ?? '';
    _descriptionController.text = widget.transaction?.description ?? '';

    txProvider.setDefaultSelectedStore();
    txProvider.setDefaultSelectedCategory();
    if (widget.transaction?.storeId != null) {
      txProvider.setSelectedStoreById(widget.transaction!.storeId);
    }

    receiptUrl = widget.transaction?.receiptUrl;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onStoreChanged(StoreModel? newStore) {
    setState(() {
      txProvider.setSelectedStoreById(newStore!.id!);
      txProvider.setDefaultSelectedCategory();
    });
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final txProvider = context.read<TransactionProvider>();
    final authProvider = context.read<AuthProvider>();
    final amount = Decimal.parse(_amountController.text);

    if (_receiptImage != null) {
      receiptUrl = await _uploadReceipt(_receiptImage!);
    }
    final transaction = TransactionModel(
      userId: authProvider.user!.id,
      categoryId: txProvider.selectedCategory!.id,
      storeId: txProvider.selectedStore!.id!,
      amount: amount,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,

      receiptUrl: receiptUrl,
    );

    final success = widget.transaction == null
        ? await txProvider.addTransaction(transaction)
        : await txProvider.updateTransaction(
            widget.transaction!.id!,
            transaction,
          );

    if (success && mounted) {
      if (widget.onDismiss != null) widget.onDismiss!();
      Navigator.of(context).pop();
    }
  }

  Future<String> _uploadReceipt(File file) async {
    final supabase = Supabase.instance.client;
    var user = supabase.auth.currentUser;

    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '${user!.id}/$fileName';
      debugPrint('File path: $filePath');
      await supabase.storage
          .from(AppConstants.receiptsBucket)
          .uploadBinary(filePath, bytes)
          .then((value) => debugPrint('File uploaded: $value'));
      final imageUrlResponse = await supabase.storage
          .from(AppConstants.receiptsBucket)
          .createSignedUrl(
            filePath,
            60 * 60 * 24 * 365 * 10,
            transform: TransformOptions(quality: 80),
          );
      debugPrint('Image URL: $imageUrlResponse');
      return imageUrlResponse;
    } on StorageException catch (error) {
      debugPrint('Error uploading file: $error');
      throw Exception('Failed to upload file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TransactionProvider>(
      builder: (context, txProvider, child) {
        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _slideAnimation.value) * 100),
              child: Opacity(
                opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        decoration: BoxDecoration(
                          gradient: AppConstants.bodyGradientForCategory(
                            txProvider.selectedCategory!.name,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(isDark ? 0.3 : 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.4 : 0.2,
                              ),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                16,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    AppConstants.headerGradientForCategory(
                                      txProvider.selectedCategory!.name,
                                    ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.transaction == null
                                        ? 'New Transaction'
                                        : 'Edit Transaction',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your expense or income',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Form
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        GlassTextField(
                                          controller: _amountController,
                                          label: 'Amount',
                                          prefixText: '\$',
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter amount';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Enter valid number';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // Description
                                        const SizedBox(height: 20),

                                        Row(
                                          spacing: 8,
                                          children: [
                                            Expanded(
                                              child:
                                                  DropdownButtonFormField<
                                                    StoreModel
                                                  >(
                                                    initialValue: txProvider
                                                        .selectedStore,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Store',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                    items: txProvider.stores.map(
                                                      (store) {
                                                        return DropdownMenuItem(
                                                          value: store,
                                                          child: Text(
                                                            store.name,
                                                          ),
                                                        );
                                                      },
                                                    ).toList(),
                                                    onChanged: _onStoreChanged,
                                                    validator: (value) =>
                                                        value == null
                                                        ? 'Select store'
                                                        : null,
                                                  ),
                                            ),
                                            IconButton.filled(
                                              color: AppColors.logo,
                                              onPressed: () =>
                                                  showManageBottomSheet(
                                                    context: context,
                                                    title: 'Stores',
                                                  ),
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        GlassTextField(
                                          controller: _descriptionController,
                                          label: 'Description',
                                          prefix: Icons.description,
                                          maxLines: 2,
                                        ),

                                        // DropdownButtonFormField<CategoryModel>(
                                        //   initialValue: _selectedCategory,
                                        //   decoration: const InputDecoration(
                                        //     labelText: 'Category (optional)',
                                        //     border: OutlineInputBorder(),
                                        //   ),
                                        //   items: txProvider.categories.map((
                                        //     cat,
                                        //   ) {
                                        //     return DropdownMenuItem(
                                        //       value: cat,
                                        //       child: Text(cat.name),
                                        //     );
                                        //   }).toList(),
                                        //   onChanged: (value) => setState(
                                        //     () => _selectedCategory = value,
                                        //   ),
                                        // ),
                                        const SizedBox(height: 20),

                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.upload_file,
                                              ),
                                              label: const Text(
                                                'Upload Receipt',
                                              ),
                                              onPressed: _pickReceipt,
                                            ),
                                            const SizedBox(width: 16),
                                            if (receiptUrl != null)
                                              Expanded(
                                                child: Image.network(
                                                  receiptUrl!,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            if (_receiptImage != null)
                                              Container(
                                                width: 48,
                                                height: 32,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Image.file(
                                                  _receiptImage!,
                                                  // height: 48,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                          ],
                                        ),
                                        txProvider.errorMessage == null
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 32.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    txProvider.errorMessage
                                                        .toString(),
                                                    style: AppConstants.error,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Buttons
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        widget.transaction == null
                                            ? 'Add Transaction'
                                            : 'Update',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Reusable Glass TextField
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefix;
  final String? prefixText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefix,
    this.prefixText,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: prefix != null ? Icon(prefix, size: 20) : null,
          prefixText: prefixText,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 16 : 20,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: maxLines > 1 ? 16 : 18,
          fontWeight: maxLines > 1 ? FontWeight.w400 : FontWeight.w500,
        ),
      ),
    );
  }
}

// Reusable Glass Container
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }
}

class GlassDropdownButton<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const GlassDropdownButton({
    super.key,
    this.value,
    required this.hint,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isDense: true,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          constraints: const BoxConstraints(minHeight: 56),
        ),
        menuMaxHeight: 200,
        items: items,
        onChanged: onChanged,
        icon: Icon(Icons.expand_more, color: Colors.white.withOpacity(0.7)),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
      ),
    );
  }
}

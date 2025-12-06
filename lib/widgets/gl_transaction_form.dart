// lib/widgets/glass_transaction_form.dart
import 'dart:io';
import 'dart:ui';
import 'package:extra/core/app_constants.dart';
import 'package:extra/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import '../core/colors.dart';

class GlassTransactionForm extends StatefulWidget {
  final TransactionModel? transaction;
  final VoidCallback? onDismiss;

  const GlassTransactionForm({super.key, this.transaction, this.onDismiss});

  @override
  State<GlassTransactionForm> createState() => _GlassTransactionFormState();
}

class _GlassTransactionFormState extends State<GlassTransactionForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccount = AppConstants.accounts.first;
  String? _selectedCategory = AppConstants.categories.first;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
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

    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ✅ Receipt Picker
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
    final amount = double.parse(_amountController.text);
    String? receiptUrl;
    if (_receiptImage != null) {
      receiptUrl = await _uploadReceipt(_receiptImage!);
    }
    final transaction = TransactionModel(
      id: widget.transaction?.id ?? '',
      userId: '', // Auto-filled by Supabase RLS
      accountId: '', // Will be resolved from account name
      categoryId: '', // Will be resolved from category name
      amount: widget.transaction == null ? -amount : amount,
      date: _selectedDate,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      createdAt: DateTime.now(),
      receiptUrl: receiptUrl,
    );

    final success = widget.transaction == null
        ? await txProvider.addTransaction(transaction)
        : await txProvider.updateTransaction(transaction.id, transaction);

    if (success && mounted) {
      if (widget.onDismiss != null) widget.onDismiss!();
      Navigator.of(context).pop();
    }
  }

  // ✅ Supabase Storage Upload
  Future<String?> _uploadReceipt(File image) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('receipts')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = supabase.storage
          .from('receipts')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Receipt upload failed: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        _selectedCategory ?? '',
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.3 : 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
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
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          decoration: BoxDecoration(
                            gradient: AppConstants.headerGradientForCategory(
                              _selectedCategory ?? '',
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
                              child: Column(
                                children: [
                                  // Amount (Big Input)
                                  GlassTextField(
                                    controller: _amountController,
                                    label: 'Amount',
                                    prefixText: '\$',
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Enter amount';
                                      if (double.tryParse(value) == null)
                                        return 'Enter valid number';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  // Description
                                  GlassTextField(
                                    controller: _descriptionController,
                                    label: 'Description',
                                    prefix: Icons.description,
                                    maxLines: 2,
                                  ),

                                  const SizedBox(height: 20),

                                  // Account & Category Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GlassDropdownButton<String>(
                                          value: _selectedAccount,
                                          hint: 'Account',
                                          items: AppConstants.accounts
                                              .map(
                                                (account) => DropdownMenuItem(
                                                  value: account,
                                                  child: Text(
                                                    account,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(
                                            () => _selectedAccount = v,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: GlassDropdownButton<String>(
                                          value: _selectedCategory,
                                          hint: 'Category',
                                          items: AppConstants.categories
                                              .map(
                                                (category) => DropdownMenuItem(
                                                  value: category,
                                                  child: Text(
                                                    category,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(() {
                                            _selectedCategory = v;
                                            // Gradient changes automatically ✨
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Date Picker
                                  GlassTextField(
                                    label: 'Date',
                                    prefix: Icons.calendar_today,
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    controller: TextEditingController(
                                      text:
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    ),
                                  ),
                                ],
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
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
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
                                      borderRadius: BorderRadius.circular(16),
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
  }

  Widget _buildDropdown(
    String label,
    String? value,
    Function(String?) onChanged,
  ) {
    return GlassDropdownButton<String>(
      value: value,
      hint: label,
      items: [
        DropdownMenuItem(value: 'Main Checking', child: Text('Main Checking')),
        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
        DropdownMenuItem(value: 'Groceries', child: Text('Groceries')),
        DropdownMenuItem(value: 'Rent', child: Text('Rent')),
        DropdownMenuItem(value: 'Salary', child: Text('Salary')),
      ],
      onChanged: onChanged,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
        maxLines: maxLines ?? 1,
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
            vertical: maxLines! > 1 ? 16 : 20,
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: maxLines! > 1 ? 16 : 18,
          fontWeight: maxLines! > 1 ? FontWeight.w400 : FontWeight.w500,
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

// Reusable Glass Dropdown
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

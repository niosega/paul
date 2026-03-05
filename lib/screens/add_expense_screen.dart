import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../widgets/currency_selector.dart';
import '../widgets/tag_chip_group.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  String _selectedCurrency = currencies.first;
  String? _selectedTag;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleValidate() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid amount greater than 0.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_selectedTag == null) {
      Fluttertoast.showToast(
        msg: 'Please select a tag.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final db = await DatabaseHelper.getInstance();
      await db.insertExpense(Expense(
        amount: amount,
        currency: _selectedCurrency,
        tag: _selectedTag!,
        createdAt: DateTime.now(),
      ));

      Fluttertoast.showToast(
        msg: 'Expense saved!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      _amountController.clear();
      setState(() {
        _selectedCurrency = currencies.first;
        _selectedTag = null;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving expense.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CurrencySelector(
                  value: _selectedCurrency,
                  onChanged: (c) => setState(() => _selectedCurrency = c),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Tag', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TagChipGroup(
              selectedTag: _selectedTag,
              onSelected: (tag) => setState(() => _selectedTag = tag),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleValidate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Validate', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

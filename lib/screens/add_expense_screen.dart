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
  final _focusNode = FocusNode();
  String _selectedCurrency = currencies.first;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleValidate() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: 'Enter a valid amount.',
        backgroundColor: const Color(0xFFFF6B6B),
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    if (_selectedTag == null) {
      Fluttertoast.showToast(
        msg: 'Select a category.',
        backgroundColor: const Color(0xFFFF6B6B),
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
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
        backgroundColor: const Color(0xFF6C63FF),
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );

      _amountController.clear();
      setState(() {
        _selectedCurrency = currencies.first;
        _selectedTag = null;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving expense.',
        backgroundColor: const Color(0xFFFF6B6B),
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Text(
                          'New Expense',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        CurrencySelector(
                          value: _selectedCurrency,
                          onChanged: (c) =>
                              setState(() => _selectedCurrency = c),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Amount input card
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C2E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? cs.primary.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.07),
                            width: 1.5,
                          ),
                          boxShadow: _focusNode.hasFocus
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AMOUNT',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _selectedCurrency == 'JPY' ? '¥' : '€',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w300,
                                    color: cs.primary.withValues(alpha: 0.8),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    focusNode: _focusNode,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                      height: 1,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        letterSpacing: -1,
                                        height: 1,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Category label
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.3),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TagChipGroup(
                      selectedTag: _selectedTag,
                      onSelected: (tag) => setState(() => _selectedTag = tag),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save button — fixed at bottom, rises with keyboard
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, const Color(0xFF9C27B0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleValidate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Save Expense',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

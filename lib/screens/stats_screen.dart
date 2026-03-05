import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/month_navigator.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.refreshKey});

  final int refreshKey;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  final PageController _pageController = PageController();
  int _chartPage = 0;
  int _localRefreshKey = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteExpense(int id) async {
    final db = await DatabaseHelper.getInstance();
    await db.deleteExpense(id);
    setState(() => _localRefreshKey++);
  }

  Future<List<Expense>> _fetchExpenses() async {
    final db = await DatabaseHelper.getInstance();
    return db.getExpensesByMonth(_selectedMonth.year, _selectedMonth.month);
  }

  String _formatAmount(double amount, String currency) {
    if (currency == 'JPY') {
      return NumberFormat.currency(
              locale: 'ja_JP', symbol: '¥', decimalDigits: 0)
          .format(amount);
    }
    return NumberFormat.currency(
            locale: 'fr_FR', symbol: '€', decimalDigits: 2)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  MonthNavigator(
                    selectedMonth: _selectedMonth,
                    onChanged: (month) =>
                        setState(() => _selectedMonth = month),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Expense>>(
                key: ValueKey('${_selectedMonth}_${widget.refreshKey}_$_localRefreshKey'),
                future: _fetchExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style:
                                const TextStyle(color: Colors.white38)));
                  }

                  final expenses = snapshot.data ?? [];
                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C2E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No expenses this month',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add your first expense',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Per-currency, per-tag totals (for pie charts)
                  final currencyTagTotals = <String, Map<String, double>>{};
                  // Per-tag, per-currency totals (for breakdown rows)
                  final tagCurrencyTotals = <String, Map<String, double>>{};
                  // Grand totals per currency
                  final grandTotals = <String, double>{};

                  for (final e in expenses) {
                    currencyTagTotals.putIfAbsent(e.currency, () => {});
                    currencyTagTotals[e.currency]![e.tag] =
                        (currencyTagTotals[e.currency]![e.tag] ?? 0) + e.amount;

                    tagCurrencyTotals.putIfAbsent(e.tag, () => {});
                    tagCurrencyTotals[e.tag]![e.currency] =
                        (tagCurrencyTotals[e.tag]![e.currency] ?? 0) + e.amount;

                    grandTotals[e.currency] =
                        (grandTotals[e.currency] ?? 0) + e.amount;
                  }

                  final activeCurrencies = currencyTagTotals.keys.toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Grand total card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6C63FF).withValues(alpha: 0.25),
                              const Color(0xFF9C27B0).withValues(alpha: 0.18),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6C63FF)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: grandTotals.entries
                                  .map((e) => Text(
                                        _formatAmount(e.value, e.key),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Pie charts — one per currency, swipeable
                      SizedBox(
                        height: 330,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: activeCurrencies.length,
                          onPageChanged: (i) =>
                              setState(() => _chartPage = i),
                          itemBuilder: (context, i) {
                            final currency = activeCurrencies[i];
                            final symbol = currency == 'JPY' ? '¥' : '€';
                            return Container(
                              margin: EdgeInsets.only(
                                right: i < activeCurrencies.length - 1 ? 12 : 0,
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C2E),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$symbol $currency',
                                          style: const TextStyle(
                                            color: Color(0xFF6C63FF),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      if (activeCurrencies.length > 1) ...[
                                        const Spacer(),
                                        Text(
                                          'swipe',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.swipe_rounded,
                                          size: 14,
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ExpensePieChart(
                                      tagTotals:
                                          currencyTagTotals[currency]!,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (activeCurrencies.length > 1) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            activeCurrencies.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _chartPage == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _chartPage == i
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Category breakdown
                      Text(
                        'BREAKDOWN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...tagCurrencyTotals.entries.map((tagEntry) {
                        final color =
                            tagColors[tagEntry.key] ?? Colors.grey;
                        final icon =
                            tagIcons[tagEntry.key] ?? Icons.category_rounded;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C2E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  tagEntry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: tagEntry.value.entries
                                      .map((currencyEntry) => Text(
                                            _formatAmount(currencyEntry.value,
                                                currencyEntry.key),
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 14),
                      Text(
                        'EXPENSES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...expenses.map((expense) {
                        final color =
                            tagColors[expense.tag] ?? Colors.grey;
                        final icon =
                            tagIcons[expense.tag] ?? Icons.category_rounded;
                        final symbol = expense.currency == 'JPY' ? '¥' : '€';
                        final amountStr = expense.currency == 'JPY'
                            ? '$symbol${expense.amount.toStringAsFixed(0)}'
                            : '$symbol${expense.amount.toStringAsFixed(2)}';
                        final dateStr = DateFormat('dd MMM, HH:mm')
                            .format(expense.createdAt);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteExpense(expense.id!),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFF6B6B)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Color(0xFFFF6B6B),
                                size: 22,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C2E),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(icon, color: color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.tag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    amountStr,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
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

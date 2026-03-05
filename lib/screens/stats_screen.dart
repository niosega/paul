import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<List<Expense>> _fetchExpenses() async {
    final db = await DatabaseHelper.getInstance();
    return db.getExpensesByMonth(_selectedMonth.year, _selectedMonth.month);
  }

  String _formatAmount(double amount, String currency) {
    if (currency == 'JPY') {
      return NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0)
          .format(amount);
    }
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MonthNavigator(
              selectedMonth: _selectedMonth,
              onChanged: (month) => setState(() => _selectedMonth = month),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              key: ValueKey('${_selectedMonth}_${widget.refreshKey}'),
              future: _fetchExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final expenses = snapshot.data ?? [];
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses this month.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                // Build per-tag, per-currency totals
                final tagCurrencyTotals = <String, Map<String, double>>{};
                for (final e in expenses) {
                  tagCurrencyTotals.putIfAbsent(e.tag, () => {});
                  tagCurrencyTotals[e.tag]![e.currency] =
                      (tagCurrencyTotals[e.tag]![e.currency] ?? 0) + e.amount;
                }

                // Currency-agnostic totals for pie chart proportions
                final tagTotalsForChart = tagCurrencyTotals.map(
                  (tag, currencyMap) => MapEntry(
                    tag,
                    currencyMap.values.fold(0.0, (a, b) => a + b),
                  ),
                );

                // Grand totals per currency
                final grandTotals = <String, double>{};
                for (final e in expenses) {
                  grandTotals[e.currency] =
                      (grandTotals[e.currency] ?? 0) + e.amount;
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ExpensePieChart(tagTotals: tagTotalsForChart),
                    const SizedBox(height: 16),
                    const Divider(),
                    ...tagCurrencyTotals.entries.map((tagEntry) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _tagColor(tagEntry.key).withValues(alpha: 0.8),
                          radius: 10,
                        ),
                        title: Text(tagEntry.key),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: tagEntry.value.entries.map((currencyEntry) {
                            return Text(
                              _formatAmount(
                                  currencyEntry.value, currencyEntry.key),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: grandTotals.entries
                                .map((e) => Text(
                                      _formatAmount(e.value, e.key),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    const colors = {
      'Food': Color(0xFFE57373),
      'Housing': Color(0xFF64B5F6),
      'Leisure': Color(0xFF81C784),
      'Investment': Color(0xFFFFD54F),
      'Other': Color(0xFFBA68C8),
    };
    return colors[tag] ?? const Color(0xFF9E9E9E);
  }
}

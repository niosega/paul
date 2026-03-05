import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ExpensePieChart extends StatelessWidget {
  // tagTotals: tag -> total (currency-agnostic, for proportions)
  final Map<String, double> tagTotals;

  const ExpensePieChart({super.key, required this.tagTotals});

  @override
  Widget build(BuildContext context) {
    final entries =
        tagTotals.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    final sections = entries.map((e) {
      final pct = e.value / total * 100;
      final color = tagColors[e.key] ?? Colors.grey;
      return PieChartSectionData(
        value: e.value,
        color: color,
        title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 80,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: entries.map((e) {
            final color = tagColors[e.key] ?? Colors.grey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(e.key, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

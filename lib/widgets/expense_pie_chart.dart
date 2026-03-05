import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> tagTotals;

  const ExpensePieChart({super.key, required this.tagTotals});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries =
        widget.tagTotals.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    final sections = entries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final e = mapEntry.value;
      final pct = e.value / total * 100;
      final color = tagColors[e.key] ?? Colors.grey;
      final isTouched = index == _touchedIndex;
      return PieChartSectionData(
        value: e.value,
        color: color,
        title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        radius: isTouched ? 72 : 58,
        borderSide: isTouched
            ? BorderSide(color: color, width: 2)
            : const BorderSide(color: Colors.transparent),
      );
    }).toList();

    final centerLabel = _touchedIndex >= 0 && _touchedIndex < entries.length
        ? entries[_touchedIndex].key
        : '${entries.length} tags';

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 56,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        setState(() => _touchedIndex = -1);
                        return;
                      }
                      setState(() => _touchedIndex =
                          response!.touchedSection!.touchedSectionIndex);
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Spent on',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white38,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    centerLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.map((e) {
            final color = tagColors[e.key] ?? Colors.grey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

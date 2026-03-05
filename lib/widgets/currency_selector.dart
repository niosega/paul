import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: currencies
          .map((c) => ButtonSegment<String>(value: c, label: Text(c)))
          .toList(),
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

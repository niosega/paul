import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TagChipGroup extends StatelessWidget {
  final String? selectedTag;
  final ValueChanged<String> onSelected;

  const TagChipGroup({
    super.key,
    required this.selectedTag,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: predefinedTags.map((tag) {
        final color = tagColors[tag]!;
        final isSelected = selectedTag == tag;
        return ChoiceChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => onSelected(tag),
          backgroundColor: color.withValues(alpha: 0.15),
          selectedColor: color.withValues(alpha: 0.85),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(color: color, width: isSelected ? 2 : 1),
        );
      }).toList(),
    );
  }
}

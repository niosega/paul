import 'package:flutter/material.dart';

const List<String> predefinedTags = [
  'Food',
  'Housing',
  'Leisure',
  'Investment',
  'Other',
];

const List<String> currencies = ['JPY', 'EUR'];

const Map<String, Color> tagColors = {
  'Food': Color(0xFFFF6B6B),
  'Housing': Color(0xFF4ECDC4),
  'Leisure': Color(0xFF45B7D1),
  'Investment': Color(0xFFFFD93D),
  'Other': Color(0xFFA29BFE),
};

const Map<String, IconData> tagIcons = {
  'Food': Icons.restaurant_rounded,
  'Housing': Icons.home_rounded,
  'Leisure': Icons.sports_esports_rounded,
  'Investment': Icons.trending_up_rounded,
  'Other': Icons.category_rounded,
};

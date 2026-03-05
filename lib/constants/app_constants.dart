import 'package:flutter/material.dart';

const List<String> predefinedTags = [
  'Courses',
  'Café',
  'Restaurant',
  'Housing',
  'Leisure',
  'Investment',
  'Other',
];

const List<String> currencies = ['JPY', 'EUR'];

const Map<String, Color> tagColors = {
  'Courses': Color(0xFFFF6B6B),
  'Café': Color(0xFFD4A76A),
  'Restaurant': Color(0xFFFF8C42),
  'Housing': Color(0xFF4ECDC4),
  'Leisure': Color(0xFF45B7D1),
  'Investment': Color(0xFFFFD93D),
  'Other': Color(0xFFA29BFE),
};

const Map<String, IconData> tagIcons = {
  'Courses': Icons.shopping_cart_rounded,
  'Café': Icons.local_cafe_rounded,
  'Restaurant': Icons.dinner_dining_rounded,
  'Housing': Icons.home_rounded,
  'Leisure': Icons.sports_esports_rounded,
  'Investment': Icons.trending_up_rounded,
  'Other': Icons.category_rounded,
};

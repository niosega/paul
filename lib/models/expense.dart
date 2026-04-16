import '../constants/app_constants.dart';

final _validCurrencies = currencies.toSet();
final _validTags = predefinedTags.toSet();

class Expense {
  final int? id;
  final double amount;
  final String currency;
  final String tag;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.currency,
    required this.tag,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'currency': currency,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    final currency = map['currency'] as String;
    final tag = map['tag'] as String;
    final amount = (map['amount'] as num).toDouble();
    if (!_validCurrencies.contains(currency)) {
      throw FormatException('Invalid currency: $currency');
    }
    if (!_validTags.contains(tag)) {
      throw FormatException('Invalid tag: $tag');
    }
    if (amount <= 0 || amount > 99999999) {
      throw FormatException('Amount out of range: $amount');
    }
    return Expense(
      id: map['id'] as int?,
      amount: amount,
      currency: currency,
      tag: tag,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

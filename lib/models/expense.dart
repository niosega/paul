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
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      tag: map['tag'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class Expense {
  final String id;
  final String categoryId;
  final String subcategoryId;
  final double amount;
  final DateTime date;
  final String notes;
  final String payeeName;

  Expense({
    required this.id,
    required this.categoryId,
    required this.subcategoryId,
    required this.amount,
    required this.date,
    required this.notes,
    required this.payeeName
  });

  // Convert a JSON object to an Expense instance
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      categoryId: json['categoryId'],
      subcategoryId: json['subcategoryId'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      payeeName: json['payeeName']
    );
  }

  // Convert an Expense instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'payeeName': payeeName
    };
  }
}

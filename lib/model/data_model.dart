import 'dart:convert';

class Trade {
  final double amount;
  final bool isProfit;
  final DateTime date;

  Trade({
    required this.amount,
    required this.isProfit,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'isProfit': isProfit,
        'date': date.toIso8601String(), // Serialize DateTime to ISO 8601 string
      };

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        amount: json['amount'],
        isProfit: json['isProfit'],
        date: DateTime.parse(json['date']), // Deserialize ISO 8601 string to DateTime
      );
}

import 'dart:convert';

class Trade {
  final double amount;
  final bool isProfit;

  Trade({required this.amount, required this.isProfit});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'isProfit': isProfit,
      };

  static Trade fromJson(Map<String, dynamic> json) => Trade(
        amount: json['amount'],
        isProfit: json['isProfit'],
      );
}

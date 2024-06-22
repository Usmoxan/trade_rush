class PnLData {
  final double amount;
  final bool isProfit;

  PnLData({required this.amount, required this.isProfit});

  factory PnLData.fromJson(Map<String, dynamic> json) {
    return PnLData(
      amount: json['amount'].toDouble(),
      isProfit: json['isProfit'],
    );
  }
}

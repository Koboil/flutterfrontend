// transaction.dart
class Transaction {
  final int transactionId;
  final int fromUserId;
  final int toUserId;
  final int tokens;
  final DateTime transferDate;

  Transaction({
    required this.transactionId,
    required this.fromUserId,
    required this.toUserId,
    required this.tokens,
    required this.transferDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      tokens: json['tokens'],
      transferDate: DateTime.parse(json['transfer_date']),
    );
  }
}

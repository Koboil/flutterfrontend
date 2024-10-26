// models/token.dart
class Token {
  final String tokenId;
  final int amount;
  final int purchasedBy;
  final DateTime purchaseDate;

  Token({
    required this.tokenId,
    required this.amount,
    required this.purchasedBy,
    required this.purchaseDate,
  });

  // Method to convert JSON data into a Token object
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      tokenId: json['token_id'],
      amount: json['amount'],
      purchasedBy: json['purchased_by'],
      purchaseDate: DateTime.parse(json['purchase_date']),
    );
  }
}

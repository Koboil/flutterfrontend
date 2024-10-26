class RaffleTicket {
  final int raffleTicketId;
  final String purchaseDate;
  final int userId;
  final int raffleId;

  RaffleTicket({
    required this.raffleTicketId,
    required this.purchaseDate,
    required this.userId,
    required this.raffleId,
  });

  factory RaffleTicket.fromJson(Map<String, dynamic> json) {
    return RaffleTicket(
      raffleTicketId: json['raffle_ticket_id'],
      purchaseDate: json['purchase_date'],
      userId: json['user_id'],
      raffleId: json['raffle_id'],
    );
  }
}

class Raffle {
  final int raffleId;
  final int organizerId;
  final String raffleName;
  final int ticketPrice;
  final String prizeDetails;
  final String startDate;
  final String endDate;

  Raffle({
    required this.raffleId,
    required this.organizerId,
    required this.raffleName,
    required this.ticketPrice,
    required this.prizeDetails,
    required this.startDate,
    required this.endDate,
  });

  factory Raffle.fromJson(Map<String, dynamic> json) {
    return Raffle(
      raffleId: json['raffle_id'],
      organizerId: json['organizer_id'],
      raffleName: json['raffle_name'],
      ticketPrice: json['ticket_price'],
      prizeDetails: json['prize_details'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

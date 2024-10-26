import 'package:flutter/material.dart';
import 'package:fairground_flutter_app/models/raffle.dart';
import 'package:fairground_flutter_app/models/raffle_ticket.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:intl/intl.dart';

class RafflesPage extends StatefulWidget {
  const RafflesPage({Key? key}) : super(key: key);

  @override
  _RafflesPageState createState() => _RafflesPageState();
}

class _RafflesPageState extends State<RafflesPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Raffle>?> rafflesFuture;
  late Future<List<RaffleTicket>?> ticketsFuture;

  late TabController _tabController; // TabController to manage tab state
  int _ticketLimit = 5; // Limit for initially displayed tickets

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    rafflesFuture = fetchRaffles();
    ticketsFuture = fetchRaffleTickets();

    _tabController.addListener(() {
      // Refresh data on tab change
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          rafflesFuture = fetchRaffles(); // Refresh raffles
        } else {
          ticketsFuture = fetchRaffleTickets(); // Refresh tickets
        }
        setState(() {}); // Trigger a rebuild to reflect changes
      }
    });
  }

  String formatDate(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  Future<void> _confirmAndPurchaseTicket(int raffleId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Purchase"),
          content: Text("Are you sure you want to purchase this ticket?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Purchase"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Proceed with ticket purchase if confirmed
      final result = await purchaseRaffleTicket(raffleId);
      final message = result['error'] ?? result['success'];

      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Optionally refresh the tickets list if the purchase is successful
      if (result['success'] != null) {
        ticketsFuture = fetchRaffleTickets(); // Refresh tickets after purchase
        setState(() {}); // Trigger a rebuild
      }
    }
  }

  void _loadMoreTickets() {
    setState(() {
      _ticketLimit += 5; // Increase the limit by 5 each time
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Raffles"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Raffles"),
            Tab(text: "My Tickets"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Raffle>?>(
            future: rafflesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error fetching raffles"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No raffles available"));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final raffle = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              raffle.raffleName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Prize: ${raffle.prizeDetails}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Ticket Price: ${raffle.ticketPrice}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Start: ${formatDate(raffle.startDate)}'),
                                Text('End: ${formatDate(raffle.endDate)}'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  onPressed: () => _confirmAndPurchaseTicket(
                                      raffle.raffleId),
                                  child: Text("Purchase Ticket",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          FutureBuilder<List<RaffleTicket>?>(
            future: ticketsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error fetching tickets"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No tickets available"));
              } else {
                // Get the tickets and reverse them for new-to-old order
                List<RaffleTicket> tickets = snapshot.data!;
                tickets.sort((a, b) => DateTime.parse(b.purchaseDate).compareTo(
                    DateTime.parse(a.purchaseDate))); // Sort from new to old

                // Limit tickets displayed based on _ticketLimit
                List<RaffleTicket> displayedTickets =
                    tickets.take(_ticketLimit).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = displayedTickets[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ticket ID: ${ticket.raffleTicketId}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Raffle ID: ${ticket.raffleId}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Purchase Date: ${formatDate(ticket.purchaseDate)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (tickets.length >
                        _ticketLimit) // Only show button if there are more tickets to load
                      TextButton(
                        onPressed: _loadMoreTickets,
                        child: Text("View More"),
                      ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fairground_flutter_app/models/transaction.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

class TransactionHistory extends StatefulWidget {
  final int? currentUser;
  const TransactionHistory({super.key, required this.currentUser});

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<Transaction> _transactions = []; // Store all transactions
  List<Transaction> _displayedTransactions =
      []; // Store transactions to display
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0; // Track the current index for pagination
  final int _loadLimit = 5; // Number of transactions to load at a time

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final transactionsData = await fetchUserTransactions();

    if (transactionsData == null) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load transactions or unauthorized.';
      });
      return;
    }

    setState(() {
      // Load transactions in reverse order
      _transactions = transactionsData
          .map((json) => Transaction.fromJson(json))
          .toList()
          .reversed
          .toList();
      _displayedTransactions =
          _transactions.take(_loadLimit).toList(); // Load initial transactions
      _isLoading = false;
    });
  }

  void _loadMoreTransactions() {
    setState(() {
      _currentIndex += _loadLimit; // Increment the current index
      // Load more transactions
      final additionalTransactions =
          _transactions.skip(_currentIndex).take(_loadLimit).toList();
      _displayedTransactions
          .addAll(additionalTransactions); // Add to displayed transactions
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _displayedTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _displayedTransactions[index];
                          // Determine icon color based on fromUserId and currentUser
                          final iconColor =
                              transaction.fromUserId == widget.currentUser
                                  ? Colors.red
                                  : Colors.green;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: Icon(
                                Icons.monetization_on_rounded,
                                size: 40,
                                color: iconColor, // Use dynamic color
                              ),
                              title: Text(
                                  'Transaction ID: ${transaction.transactionId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tokens: ${transaction.tokens}'),
                                  Text('From User: ${transaction.fromUserId}'),
                                  Text('To User: ${transaction.toUserId}'),
                                  Text('Date: ${transaction.transferDate}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_currentIndex + _loadLimit < _transactions.length)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _loadMoreTransactions,
                          child: const Text('Load More'),
                        ),
                      ),
                  ],
                ),
    );
  }
}

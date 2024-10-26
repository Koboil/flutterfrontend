import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/pages/user_screens/parent_home_page.dart';
import 'package:flutter/material.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:fairground_flutter_app/models/token.dart';

class PurchaceTokenPage extends StatefulWidget {
  const PurchaceTokenPage({Key? key}) : super(key: key);

  @override
  _PurchaceTokenPageState createState() => _PurchaceTokenPageState();
}

class _PurchaceTokenPageState extends State<PurchaceTokenPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false; // Track loading state
  String _message = ''; // Store success/error messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Tokens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter amount of tokens to purchase:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
            const SizedBox(height: 16),
            MyButton(
              onTap: _isLoading ? null : _purchaseTokens,
              text: "Purchase",
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseTokens() async {
    if (_amountController.text.isEmpty) {
      setState(() {
        _message = 'Please enter an amount.';
      });
      return;
    }

    final int amount = int.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      setState(() {
        _message = 'Amount must be greater than zero.';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
      _message = ''; // Clear previous messages
    });

    try {
      Token newToken =
          await purchaseTokens(amount); // Call purchaseTokens function

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Purchase Successful'),
            content: Text('Successfully purchased ${newToken.amount} tokens!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ParentHomePage()), // Replace with your login/register page
                    (route) => false, // Remove all previous routes
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _message = 'Failed to purchase tokens: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
}

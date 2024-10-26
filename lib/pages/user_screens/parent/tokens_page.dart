import 'package:fairground_flutter_app/components/balance_widget.dart';
import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/models/token.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/pages/user_screens/parent/purchace_token_page.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class TokensPage extends StatefulWidget {
  const TokensPage({Key? key}) : super(key: key);

  @override
  _TokensPageState createState() => _TokensPageState();
}

class _TokensPageState extends State<TokensPage> {
  User? user;
  List<Token> tokenPurchaseHistory = [];
  int itemsToShow = 5; // Number of items to show initially and for "Load More"
  bool isLoading = true; // Track loading state
  bool isLoadingMore = false; // Track load more state

  void initialize() async {
    User? fetchedUser = await fetchUserData();

    if (fetchedUser == null) {
      logout(context);
      return;
    }

    List<Token> fetchedTokenPurchaseHistory = await fetchTokenHistory();

    setState(() {
      user = fetchedUser;
      tokenPurchaseHistory = fetchedTokenPurchaseHistory.reversed.toList();
      isLoading = false; // Stop loading when data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Fetch data during initialization
  }

  void loadMore() {
    setState(() {
      isLoadingMore = true; // Show loading for more items
    });

    // Simulate a delay (if loading from API, this is where the logic would go)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Increase the number of items to show by 5
        itemsToShow += 5;

        // Stop showing load more indicator
        isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tokens'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                BalanceWidget(
                    balance: user?.tokensBalance ?? 0), // Show user balance
                const SizedBox(height: 15),
                MyButton(
                    onTap: () {
                      // Navigate to purchase page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PurchaceTokenPage()),
                      );
                    },
                    text: "Purchase"),
                const SizedBox(height: 25),
                // Token Purchase History List
                Expanded(
                  child: ListView.builder(
                    itemCount: itemsToShow < tokenPurchaseHistory.length
                        ? itemsToShow + 1 // +1 for "Load More" button
                        : tokenPurchaseHistory.length,
                    itemBuilder: (context, index) {
                      if (index == itemsToShow &&
                          itemsToShow < tokenPurchaseHistory.length) {
                        // "Load More" button
                        return Center(
                          child: ElevatedButton(
                            onPressed: loadMore,
                            child: isLoadingMore
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Load More'),
                          ),
                        );
                      } else if (index < tokenPurchaseHistory.length) {
                        final token = tokenPurchaseHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: const Icon(Icons.monetization_on_rounded,
                                size: 40, color: Colors.green),
                            title: Text('Token ID: ${token.tokenId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount: ${token.amount}'),
                                Text(
                                    'Purchase Date: ${token.purchaseDate.toLocal()}'),
                              ],
                            ),
                          ),
                        );
                      }
                      return Container(); // Empty container for any other cases
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

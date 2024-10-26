import 'package:fairground_flutter_app/components/balance_widget.dart';
import 'package:fairground_flutter_app/components/my_drawer.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class StandHolderHomePage extends StatefulWidget {
  const StandHolderHomePage({Key? key}) : super(key: key);

  @override
  _StandHolderHomePageState createState() => _StandHolderHomePageState();
}

class _StandHolderHomePageState extends State<StandHolderHomePage> {
  User? user; // To store user data
  bool isLoading = true; // Track loading state
  int _selectedIndex = 0; // Track selected tab

  // Fetch user data and initialize the screen
  void initialize() async {
    User? fetchedUser = await fetchUserData(); // Fetch user data

    if (fetchedUser == null) {
      logout(context); // If no user is fetched, log out
      return;
    }

    setState(() {
      user = fetchedUser; // Store fetched user data
      isLoading = false; // Stop loading when data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Fetch data during initialization
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      initialize(); // Refresh user data when home tab is tapped
    }

    setState(() {
      _selectedIndex = index; // Update selected tab index
    });
  }

  // Replace this with relevant pages for fairground management
  Widget _getPage(int? userId) {
    switch (_selectedIndex) {
      case 0:
        return isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner
            : Column(
                children: [
                  BalanceWidget(balance: user?.tokensBalance ?? 0),
                ],
              );
      case 1:
        return const Center(
            child: Text(
          'Management Settings',
          style: TextStyle(fontSize: 18),
        )); // Placeholder for Manage Rides page
      case 2:
        return const Center(
            child: Text(
          'Transaction History',
          style: TextStyle(fontSize: 18),
        )); // Placeholder for Transaction History page
      default:
        return Container(); // Fallback page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(user: user), // Pass user data to the drawer
      appBar: AppBar(
        title: const Text('Stand Holder'),
      ),
      body: _getPage(user?.userId), // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transactions',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 16,
        unselectedFontSize: 14,
      ),
    );
  }
}

import 'package:fairground_flutter_app/components/balance_widget.dart';
import 'package:fairground_flutter_app/components/my_drawer.dart';
import 'package:fairground_flutter_app/components/points_widget.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/pages/raffles_page.dart';
import 'package:fairground_flutter_app/pages/stalls_page.dart';
import 'package:fairground_flutter_app/pages/transaction_history.dart';
import 'package:fairground_flutter_app/pages/user_screens/student/student_parent_view.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  User? user;
  bool isLoading = true; // Track loading state
  int _selectedIndex = 0; // Track selected tab

  void initialize() async {
    User? fetchedUser = await fetchUserData();

    if (fetchedUser == null) {
      logout(context);
      return;
    }

    setState(() {
      user = fetchedUser;
      isLoading = false; // Stop loading when data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Fetch data during initialization
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected tab index
    });
  }

  // A method to switch between the different pages
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 25),
                  BalanceWidget(
                      balance:
                          user?.tokensBalance ?? 0), // Use fetched user data
                  SizedBox(height: 15),
                  PointsWidget(point: user?.pointsEarned ?? 0),
                  SizedBox(height: 25),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        childAspectRatio: 2 / 1, // Aspect ratio for card height
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 2,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      itemBuilder: (context, index) {
                        final labels = [
                          "Stalls",
                          "Raffles",
                        ];
                        final icons = [
                          Icons.account_balance,
                          Icons.event,
                        ];
                        final routes = [StallsPage(), RafflesPage()];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => routes[index]),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Slight shadow color
                                  blurRadius: 6, // How blurry the shadow is
                                  offset: Offset(
                                      0, 0), // Even shadow around the card
                                  spreadRadius:
                                      1, // Spread radius for shadow expansion
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icons[index], size: 30),
                                SizedBox(height: 8),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ), // Use fetched user data
                ],
              );
      case 1:
        return const StudentParentView(); // Display the parents view
      case 2:
        return TransactionHistory(
            currentUser: user?.userId); // Show transaction history
      default:
        return Container(); // Fallback in case index is out of bounds
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(user: user),
      appBar: AppBar(
        title: Text('Student'),
      ),
      body: _getPage(_selectedIndex), // Switch between pages using _getPage
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_rounded),
            label: 'Parents',
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

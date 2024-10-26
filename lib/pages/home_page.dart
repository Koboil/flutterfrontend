import 'package:fairground_flutter_app/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Instance of secure storage
  String? token; // Variable to hold the token

  @override
  void initState() {
    super.initState();
    _getToken(); // Retrieve the token when the page initializes
  }

  // Method to get the token from secure storage
  Future<void> _getToken() async {
    final storedToken = await storage.read(key: 'token'); // Read the token
    setState(() {
      token = storedToken; // Set the state with the retrieved token
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      // drawer: MyDrawer(),
      body: Center(
        child: token != null
            ? Text(
                'Token: $token', // Display the token
                style: TextStyle(fontSize: 16),
              )
            : CircularProgressIndicator(), // Show a loading indicator while fetching
      ),
    );
  }
}

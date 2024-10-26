import 'package:flutter/material.dart';

class StallsPage extends StatefulWidget {
  const StallsPage({Key? key}) : super(key: key);

  @override
  _StallsPageState createState() => _StallsPageState();
}

class _StallsPageState extends State<StallsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stalls"),
      ),
      body: Center(
        child: Text("Stalls"),
      ),
    );
  }
}

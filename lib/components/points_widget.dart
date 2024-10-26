import 'package:flutter/material.dart';

class PointsWidget extends StatefulWidget {
  const PointsWidget({super.key, required this.point});
  final int point;

  @override
  _PointsWidgetState createState() => _PointsWidgetState();
}

class _PointsWidgetState extends State<PointsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 25, 20),
      margin: EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(
        //   color: Theme.of(context)
        //       .colorScheme
        //       .inversePrimary, // Set the color of the border to black
        //   width: 1, // Set the width of the border
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Slight shadow color
            blurRadius: 6, // How blurry the shadow is
            offset: Offset(0, 0), // Even shadow around the card
            spreadRadius: 1, // Spread radius for shadow expansion
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Points Earned",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary))
            ],
          ),
          Row(
            children: [
              Icon(Icons.monetization_on),
              SizedBox(width: 5),
              Text('${widget.point}' + " Points",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          )
        ],
      ),
    );
  }
}

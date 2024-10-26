import 'package:flutter/material.dart';

class BalanceWidget extends StatefulWidget {
  const BalanceWidget(
      {super.key, required this.balance, this.showPurchaseIcon = false});
  final int balance;
  final bool showPurchaseIcon;

  @override
  _BalanceWidgetState createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 25, 20),
      margin: EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Token Balance",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.monetization_on),
              SizedBox(width: 5),
              Text('${widget.balance}' + " Tokens",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(width: 10),
              if (widget.showPurchaseIcon)
                Icon(
                  Icons.add,
                  color: Colors.green,
                  size: 25,
                ),
            ],
          )
        ],
      ),
    );
  }
}

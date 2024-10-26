import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  bool isLoading = false;

  MyButton(
      {super.key,
      required this.onTap,
      required this.text,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
        margin: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: isLoading
              ? SizedBox(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  height: 18,
                  width: 18,
                )
              : Text(
                  text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
        ),
      ),
    );
  }
}

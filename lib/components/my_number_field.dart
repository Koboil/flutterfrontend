import 'package:flutter/material.dart';

class MyNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;

  const MyNumberField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            errorText: errorText,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            )),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              width: 1.5,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
    );
  }
}

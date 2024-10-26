import 'package:flutter/material.dart';

class StudentInfoWidget extends StatelessWidget {
  final String name;
  final String email;
  final String userId;

  const StudentInfoWidget({
    Key? key,
    required this.name,
    required this.email,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 25, 20),
      width: double.infinity, // Make the container take the full width
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: "Email: ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: email),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: "User ID: ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

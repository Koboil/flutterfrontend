import 'package:fairground_flutter_app/auth/login_or_register.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fairground_flutter_app/components/my_drawer_tile.dart';
import 'package:fairground_flutter_app/pages/settings_page.dart';

import 'package:fairground_flutter_app/auth/login_or_register.dart'; // Import your login/register page

class MyDrawer extends StatelessWidget {
  final User? user;
  MyDrawer({super.key, required this.user});

  // Create a FlutterSecureStorage instance
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Logout function

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 100, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.account_circle_rounded,
                        size: 60,
                        color: Theme.of(context).colorScheme.inversePrimary),
                    horizontalTitleGap: 10,
                    title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user?.firstName}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontWeight: FontWeight.w700)),
                          Text("${user?.lastName}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontWeight: FontWeight.w700))
                        ])),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.inversePrimary),
                    children: <TextSpan>[
                      const TextSpan(
                          text: "Email: ",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: "${user?.email}"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.inversePrimary),
                    children: <TextSpan>[
                      const TextSpan(
                          text: "User ID: ",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: "${user?.userId}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          MyDrawerTile(
            text: "Home",
            icon: Icons.home_rounded,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          MyDrawerTile(
            text: "Settings",
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          const Spacer(),
          MyDrawerTile(
            text: "Logout",
            icon: Icons.logout_rounded,
            onTap: () => logout(context), // Call the logout function here
          ),
        ],
      ),
    );
  }
}

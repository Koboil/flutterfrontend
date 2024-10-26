import 'package:flutter/material.dart';
import 'package:fairground_flutter_app/pages/user_screens/fairground_management_home_page.dart';
import 'package:fairground_flutter_app/pages/user_screens/organizer_home_page.dart';
import 'package:fairground_flutter_app/pages/user_screens/parent_home_page.dart';
import 'package:fairground_flutter_app/pages/user_screens/stand_holder_home_page.dart';
import 'package:fairground_flutter_app/pages/user_screens/student_home_page.dart';
import 'package:fairground_flutter_app/auth/login_or_register.dart';

Widget GetHomePage(String role) {
  switch (role) {
    case "parent":
      return ParentHomePage();
    case "student":
      return StudentHomePage();
    case "stand-holder":
      return StandHolderHomePage();
    case "organizer":
      return OrganizerHomePage();
    case "fairground-management":
      return FairgroundManagementHomePage();
    default:
      return LoginOrRegister();
  }
}

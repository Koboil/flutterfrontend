import 'package:fairground_flutter_app/components/get_home_page.dart';
import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/components/my_textfield.dart';
import 'package:fairground_flutter_app/pages/home_page.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.onTap});
  final void Function()? onTap;

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  final FlutterSecureStorage storage = FlutterSecureStorage();

  void validateAndRegister() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final role = roleController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
        isLoading = false;
      });
      return;
    }

    // Simple email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
        isLoading = false;
      });
      return;
    }

    // Password validation (at least 6 characters)
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long.';
        isLoading = false;
      });
      return;
    }

    // Clear error messages before making API call
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    // Call the registration method
    registerUser(firstName, lastName, email, password, role);
  }

  Future<void> registerUser(String firstName, String lastName, String email,
      String password, String role) async {
    var url = '$baseUrl/api/v1/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        // Save token securely
        await storage.write(key: 'token', value: token);

        var user = await fetchUserData();
        Widget page = GetHomePage(user!.role);

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      } else {
        // Handle server errors (like 400, 500)
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          errorMessage =
              responseData['error'] ?? 'Registration failed. Please try again.';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.lock_open_rounded,
              size: 90,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            Text(
              "Fairground Management",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextfield(
                    controller: firstNameController,
                    hintText: "First Name",
                    obscureText: false,
                    padding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                  ),
                ),
                Expanded(
                  child: MyTextfield(
                    controller: lastNameController,
                    hintText: "Last Name",
                    obscureText: false,
                    padding: const EdgeInsets.fromLTRB(5, 0, 25, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MyTextfield(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
              padding: const EdgeInsets.symmetric(horizontal: 25),
            ),
            const SizedBox(height: 10),
            MyTextfield(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
            ),
            const SizedBox(height: 10),
            MyTextfield(
              controller: roleController,
              hintText: "Role",
              obscureText: false,
              padding: const EdgeInsets.symmetric(horizontal: 25),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            MyButton(
              onTap: () {
                setState(() {
                  isLoading = true;
                });
                validateAndRegister();
              },
              text: "Register",
              isLoading: isLoading,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already a member?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

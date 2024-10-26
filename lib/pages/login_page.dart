import 'dart:convert';
import 'package:fairground_flutter_app/components/get_home_page.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/components/my_textfield.dart';
import 'package:fairground_flutter_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:email_validator/email_validator.dart'; 

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Access the secure storage instance
  final FlutterSecureStorage storage = FlutterSecureStorage();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    // Validate email format
    if (!EmailValidator.validate(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    final url = Uri.parse('$baseUrl/api/v1/auth/login');

    try {
      setState(() {
        isLoading = true; // Set loading state
        errorMessage = ''; // Clear previous error message
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
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
        // Extract error message from response
        setState(() {
          errorMessage = jsonDecode(response.body)['error'] ??
              'Login failed. Please try again.';
        });
      }
    } catch (e) {
      // Handle any other errors
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
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
            const SizedBox(height: 100),
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
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 25),
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
            if (errorMessage.isNotEmpty) // Display error message if it exists
              Text(
                errorMessage,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            const Spacer(),
            MyButton(
              onTap: login,
              text: "Sign In",
              isLoading: isLoading,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member?",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary),
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

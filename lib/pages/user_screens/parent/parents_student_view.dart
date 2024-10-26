import 'package:fairground_flutter_app/components/balance_widget.dart';
import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/components/my_drawer.dart';
import 'package:fairground_flutter_app/components/my_number_field.dart';
import 'package:fairground_flutter_app/components/points_widget.dart';
import 'package:fairground_flutter_app/components/student_info_widget.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ParentsStudentView extends StatefulWidget {
  final User student;

  const ParentsStudentView({Key? key, required this.student}) : super(key: key);

  @override
  _ParentsStudentViewState createState() => _ParentsStudentViewState();
}

class _ParentsStudentViewState extends State<ParentsStudentView> {
  User? studentData; // To hold the fetched student data
  bool isLoading = true; // Track loading state
  bool isTransferVisible = false; // Track visibility of the transfer field
  String transferError = ''; // To hold any transfer error messages
  final TextEditingController _tokenController =
      TextEditingController(); // Controller for the input field

  void initialize() async {
    // Fetch student data using the student ID from the passed User object
    User? fetchedStudent = await fetchStudentData(widget.student.userId);

    if (fetchedStudent == null) {
      logout(context); // Log out if fetching fails
      return;
    }

    setState(() {
      studentData = fetchedStudent; // Update state with fetched data
      isLoading = false; // Stop loading when data is fetched
    });
  }

  Future<void> transferTokens() async {
    // Parse the number of tokens from the controller
    int tokensToTransfer = int.tryParse(_tokenController.text) ?? 0;

    if (tokensToTransfer <= 0) {
      setState(() {
        transferError = 'Please enter a valid number of tokens.';
      });
      return;
    }

    // Call the transferTokens function from the API service
    final result =
        await tokensTransfer(widget.student.userId, tokensToTransfer);

    if (result != null && result.containsKey('error')) {
      setState(() {
        transferError = result['error'];
      });
    } else {
      setState(() {
        transferError = ''; // Clear any previous error messages
        isTransferVisible = false; // Hide the transfer field
        // Refresh student data to show updated tokens
        initialize();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer successful!')),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Fetch data during initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ) // Show loading spinner
          : Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudentInfoWidget(
                    // Use the new widget for student info
                    name: "${studentData?.firstName} ${studentData?.lastName}",
                    email: "${studentData?.email}",
                    userId: "${studentData?.userId}",
                  ),
                  SizedBox(height: 15),
                  BalanceWidget(balance: studentData?.tokensBalance ?? 0),
                  SizedBox(height: 15),
                  PointsWidget(point: studentData?.pointsEarned ?? 0),
                  SizedBox(height: 15),
                  if (isTransferVisible) ...[
                    MyNumberField(
                      controller: _tokenController,
                      hintText: "Enter number of tokens",
                      obscureText: false,
                      errorText:
                          transferError.isNotEmpty ? transferError : null,
                    ),
                    SizedBox(height: 10),
                    MyButton(
                      text:
                          "Transfer", // Keeping the button for executing the transfer
                      onTap: transferTokens,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                  MyButton(
                    text: isTransferVisible
                        ? "Cancel"
                        : "Give Tokens", // Changed the button text
                    onTap: () {
                      setState(() {
                        isTransferVisible =
                            !isTransferVisible; // Toggle visibility of transfer field
                        transferError = ''; // Clear error message when toggling
                      });
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

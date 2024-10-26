import 'package:fairground_flutter_app/components/balance_widget.dart';
import 'package:fairground_flutter_app/components/my_button.dart';
import 'package:fairground_flutter_app/components/my_drawer.dart';
import 'package:fairground_flutter_app/components/student_info_widget.dart';
import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class StudentParentView extends StatefulWidget {
  const StudentParentView({super.key});

  @override
  _StudentParentViewState createState() => _StudentParentViewState();
}

class _StudentParentViewState extends State<StudentParentView> {
  List<User>? parentsData; // To hold the fetched parents data
  bool isLoading = true; // Track loading state
  bool _isAddingParent = false; // Track when to show add parent form
  final TextEditingController _emailController =
      TextEditingController(); // For email input
  String? _errorMessage; // To show validation or API error messages

  void initialize() async {
    // Fetch parents data using the fetchParents function
    List<User>? fetchedParents = await fetchParents();

    if (fetchedParents == null) {
      logout(context); // Log out if fetching fails
      return;
    }

    setState(() {
      parentsData = fetchedParents; // Update state with fetched parents data
      isLoading = false; // Stop loading when data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    initialize(); // Fetch parents data during initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parents Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isAddingParent
                ? null // Disable the button if the form is shown
                : () {
                    setState(() {
                      _isAddingParent = true; // Show the form
                      _errorMessage = null; // Reset error message
                    });
                  },
          ),
        ],
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
                  const SizedBox(height: 15),

                  // Show the form to add parent if _isAddingParent is true
                  if (_isAddingParent) _buildAddParentForm(),

                  Expanded(
                    child: ListView.builder(
                      itemCount: parentsData?.length ?? 0,
                      itemBuilder: (context, index) {
                        User parent = parentsData![index];
                        return Column(
                          children: [
                            _buildParentCard(parent),
                            const SizedBox(height: 15),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildParentCard(User parent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${parent.firstName} ${parent.lastName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Email: ${parent.email}'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(parent),
          ),
        ],
      ),
    );
  }

  Widget _buildAddParentForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter parent email',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              errorText: _errorMessage, // Show error message if there's any
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAddingParent = false;
                    _emailController.clear();
                    _errorMessage = null; // Clear error message
                  });
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _addParent,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addParent() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    final result = await addParentToStudent(email);

    if (mounted) {
      if (result.containsKey('success')) {
        // Hide the form and refresh the list
        setState(() {
          _isAddingParent = false;
          initialize(); // Refresh the parents data after adding
          _emailController.clear();
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'])),
        );
      } else if (result.containsKey('error')) {
        // Show error message and keep the form visible
        setState(() {
          _errorMessage = result['error'];
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(User parent) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete ${parent.firstName} ${parent.lastName}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteParent(parent.userId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteParent(int parentId) async {
    final result = await deleteParentFromStudent(parentId);

    if (result.containsKey('success')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['success'])));
      setState(() {
        initialize(); // Refresh the list after deletion
      });
    } else if (result.containsKey('error')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['error'])));
    }
  }
}

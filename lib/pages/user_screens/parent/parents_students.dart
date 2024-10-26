import 'package:fairground_flutter_app/models/user.dart';
import 'package:fairground_flutter_app/pages/settings_page.dart';
import 'package:fairground_flutter_app/pages/user_screens/parent/parents_student_view.dart';
import 'package:fairground_flutter_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ParentsStudents extends StatefulWidget {
  const ParentsStudents({Key? key}) : super(key: key);

  @override
  _ParentsStudentsState createState() => _ParentsStudentsState();
}

class _ParentsStudentsState extends State<ParentsStudents> {
  late Future<List<User>> _studentsFuture;
  bool _isAddingStudent = false; // To control when to show the form
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _studentsFuture =
        fetchStudentsData(); // Fetch students data on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isAddingStudent
                ? null // Disable the button if form is shown
                : () {
                    setState(() {
                      _isAddingStudent = true; // Show the form
                      _errorMessage = null; // Reset error message
                    });
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Show the form if _isAddingStudent is true
          if (_isAddingStudent) _buildAddStudentForm(),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found.'));
                } else {
                  final students = snapshot.data!;
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentCard(student);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(User student) {
    return GestureDetector(
      onTap: () => _navigateToStudentDetails(student),
      child: Container(
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
                    '${student.firstName} ${student.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Email: ${student.email}'),
                  Text('Tokens: ${student.tokensBalance}'),
                  Text('Points: ${student.pointsEarned}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(student),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStudentForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter student email',
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
                    _isAddingStudent = false;
                    _emailController.clear();
                    _errorMessage = null; // Clear error message
                  });
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _addStudent,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addStudent() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    final result = await addStudentToParent(email);

    if (mounted) {
      if (result != null && result == 'Student added successfully') {
        // Hide the form and refresh the list
        setState(() {
          _isAddingStudent = false;
          _studentsFuture = fetchStudentsData();
          _emailController.clear();
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
      } else {
        // Show error message and keep the form visible
        setState(() {
          _errorMessage = result ?? 'An error occurred';
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(User student) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete ${student.firstName} ${student.lastName}?'),
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
                _deleteStudent(student.userId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudent(int userId) async {
    final result = await deleteStudent(userId);

    if (result != null && result.contains('success')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      setState(() {
        _studentsFuture = fetchStudentsData();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result ?? 'An error occurred')));
    }
  }

  void _navigateToStudentDetails(User student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentsStudentView(
            student: student), // Replace with your student details page
      ),
    );
  }
}

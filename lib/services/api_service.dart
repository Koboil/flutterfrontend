import 'dart:convert';
import 'package:fairground_flutter_app/auth/login_or_register.dart';
import 'package:fairground_flutter_app/models/raffle.dart';
import 'package:fairground_flutter_app/models/raffle_ticket.dart';
import 'package:fairground_flutter_app/models/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();

var baseUrl = 'http://192.168.0.105:3000';

Future<User?> fetchUserData() async {
  String? token = await storage.read(key: 'token');

  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/user/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    return User.fromJson(data);
  } else {
    // Handle error (e.g., log out if unauthorized)
    return null;
  }
}

Future<Map<String, dynamic>> addParentToStudent(String parentEmail) async {
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return {'error': 'Token is missing, please log in again.'};
  }

  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/students/parent'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': parentEmail,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] != null) {
      return {'success': responseData['success']}; // Wrap success in a map
    }
  } else {
    final errorData = jsonDecode(response.body);
    if (errorData['error'] != null) {
      return {'error': errorData['error']}; // Return error in a map
    }
  }

  return {'error': 'Unexpected error occurred while adding the parent.'};
}

Future<String?> addStudentToParent(String email) async {
  // Retrieve the JWT token from secure storage
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return 'Unauthorized: No token found. Please log in again.';
  }

  // Define the API endpoint and request body
  final url = Uri.parse('$baseUrl/api/v1/parents/student');
  final body = jsonEncode({
    'email': email,
  });

  try {
    // Send the POST request
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != null) {
        return responseData['success']; // Return success message
      }
    } else {
      return jsonDecode(response.body)['error'];
    }
  } catch (error) {
    return 'An error occurred: $error';
  }
  return null;
}

// Fetch token history (new function)
Future<List<Token>> fetchTokenHistory() async {
  String? token = await storage.read(key: 'token');
  if (token == null) throw Exception("Token not found!");

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/tokens/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['data'];
    // Convert the response data to a list of Token objects
    return data.map((item) => Token.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load token history');
  }
}

// Purchase tokens function
Future<Token> purchaseTokens(int amount) async {
  String? token = await storage.read(key: 'token');
  if (token == null) throw Exception("Token not found!");

  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/tokens/purchase'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'amount': amount}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    return Token.fromJson(data); // Return the newly purchased Token
  } else {
    throw Exception('Failed to purchase tokens: ${response.body}');
  }
}

Future<void> logout(BuildContext context) async {
  // Remove the token from secure storage
  await storage.delete(
      key: 'token'); // Make sure the key matches your token key

  // Navigate to the login/register page
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) =>
            const LoginOrRegister()), // Replace with your login/register page
    (route) => false, // Remove all previous routes
  );
}

Future<List<User>> fetchStudentsData() async {
  String? token = await storage.read(key: 'token');
  if (token == null) throw Exception("Token not found!");

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/parents/students'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['data'];
    // Convert the response data to a list of User objects
    return data.map((item) => User.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load students data: ${response.body}');
  }
}

Future<String?> deleteStudent(int studentId) async {
  String? token =
      await storage.read(key: 'token'); // Retrieve the stored JWT token

  if (token == null) {
    return 'Error: No token found';
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/api/v1/parents/student/$studentId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] != null) {
      return responseData['success']; // Success message
    } else {
      return 'Error: Unexpected response';
    }
  } else {
    return 'Error: Unable to remove student';
  }
}

// Fetch specific student's data for the parent using studentId
Future<User?> fetchStudentData(int studentId) async {
  String? token = await storage.read(key: 'token');

  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/parents/student/$studentId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    return User.fromJson(data);
  } else {
    // Handle error (e.g., show error or handle it accordingly)
    return null;
  }
}

Future<Map<String, dynamic>?> tokensTransfer(int toUserId, int tokens) async {
  // Retrieve the JWT token from secure storage
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return {'error': 'Unauthorized: No token found. Please log in again.'};
  }

  // Define the API endpoint and request body
  final url = Uri.parse('$baseUrl/api/v1/tokens/transfer');
  final body = jsonEncode({
    'to_user_id': toUserId,
    'tokens': tokens,
  });

  try {
    // Send the POST request
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data']; // Return the transaction details
    } else {
      return {'error': jsonDecode(response.body)['error']};
    }
  } catch (error) {
    return {'error': 'An error occurred: $error'};
  }
}

Future<List<dynamic>?> fetchUserTransactions() async {
  String? token = await storage.read(key: 'token');

  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/transactions/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    return data; // Return the list of transactions
  } else {
    // Handle error (e.g., log out if unauthorized)
    return null;
  }
}

// Function to fetch parents' data
Future<List<User>?> fetchParents() async {
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return null;
  }

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/students/parents'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    List<User> parents =
        (data as List).map((parentData) => User.fromJson(parentData)).toList();
    return parents;
  } else {
    return null; // Handle the error accordingly
  }
}

Future<Map<String, dynamic>> deleteParentFromStudent(int parentId) async {
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return {'error': 'Token is missing, please log in again.'};
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/api/v1/students/parent/$parentId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] != null) {
      return {'success': responseData['success']}; // Wrap success in a map
    }
  } else {
    final errorData = jsonDecode(response.body);
    if (errorData['error'] != null) {
      return {'error': errorData['error']}; // Return error in a map
    }
  }

  return {'error': 'Unexpected error occurred while deleting the parent.'};
}

// Fetch raffles data
Future<List<Raffle>?> fetchRaffles() async {
  String? token = await storage.read(key: 'token');

  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/raffles'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((json) => Raffle.fromJson(json)).toList();
  } else {
    return [];
  }
}

// Fetch raffle tickets data
Future<List<RaffleTicket>?> fetchRaffleTickets() async {
  String? token = await storage.read(key: 'token');

  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/raffle/tickets/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((json) => RaffleTicket.fromJson(json)).toList();
  } else {
    return []; // Handle error if needed
  }
}

// Purchase a raffle ticket
Future<Map<String, dynamic>> purchaseRaffleTicket(int raffleId) async {
  String? token = await storage.read(key: 'token');

  if (token == null) {
    return {'error': 'Token is missing, please log in again.'};
  }

  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/raffle/ticket/purchase/$raffleId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] != null) {
      return {'success': responseData['success']}; // Return success message
    }
  } else {
    final errorData = jsonDecode(response.body);
    if (errorData['error'] != null) {
      return {'error': errorData['error']}; // Return error message
    }
  }

  return {'error': 'Unexpected error occurred during the ticket purchase.'};
}

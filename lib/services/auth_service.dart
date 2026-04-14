import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class AuthService {
  // Pointing to your specific live domain
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/auth';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Save user data locally
        await LocalStorageService().saveUserData(jsonEncode(data['user']));
        return {"success": true, "user": data['user']};
      } else {
        return {"success": false, "message": data['message']};
      }
    } catch (e) {
      return {"success": false, "message": "Network error occurred. Please check your connection."};
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
    String? aadhar, // Optional
    String? pan,    // Optional
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
          "aadhar": aadhar ?? "",
          "pan": pan ?? "",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['status'] == 'success') {
        return {"success": true, "message": data['message']};
      } else {
        return {"success": false, "message": data['message'] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error occurred. Please try again."};
    }
  }

  Future<void> logout() async {
     await LocalStorageService().clearUserData();
  }
}
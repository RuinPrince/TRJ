import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/local_storage_service.dart';

class AuthService {
  // Pointing to your specific live domain
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/auth';

  // THE FIX: Fake Chrome Browser Headers to bypass Hostinger Firewall
  final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json",
  };

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: _headers, // Applying security bypass
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10)); // 10-second hard stop

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        await LocalStorageService().saveUserData(jsonEncode(data['user']));
        return {"success": true, "user": data['user']};
      } else {
        return {"success": false, "message": data['message'] ?? "Invalid credentials"};
      }
    } on TimeoutException {
      return {"success": false, "message": "Connection timed out. Server blocked the request."};
    } catch (e) {
      return {"success": false, "message": "Network error occurred."};
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String city,   
    required String pincode,
    String? pan,            
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: _headers, // Applying security bypass
        body: jsonEncode({
          "full_name": fullName,
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
          "address": address,
          "city": city,
          "pincode": pincode,
          "pan_number": pan ?? "",
        }),
      ).timeout(const Duration(seconds: 10)); // 10-second hard stop

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['status'] == 'success') {
        return {"success": true, "message": data['message']};
      } else {
        return {"success": false, "message": data['message'] ?? "Registration failed"};
      }
    } on TimeoutException {
      return {"success": false, "message": "Connection timed out. Server blocked the request."};
    } catch (e) {
      return {"success": false, "message": "Network error occurred. Please try again."};
    }
  }

  Future<void> logout() async {
     await LocalStorageService().clearUserData();
  }
}
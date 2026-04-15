import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/customer';

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_profile.php?user_id=$userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') return decoded['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      final decoded = jsonDecode(response.body);
      return {
        'success': decoded['status'] == 'success',
        'message': decoded['message'] ?? 'Update failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change_password.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "current_password": currentPassword,
          "new_password": newPassword
        }),
      );
      final decoded = jsonDecode(response.body);
      return {
        'success': decoded['status'] == 'success',
        'message': decoded['message'] ?? 'Password update failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
}
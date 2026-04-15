import 'dart:convert';
import 'package:http/http.dart' as http;

class SupportService {
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/customer';

  Future<List<Map<String, dynamic>>> getTickets(String customerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/support_tickets.php?action=list&user_id=$customerId'));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return List<Map<String, dynamic>>.from(decoded['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support_tickets.php?action=create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Failed to connect to server'};
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }
}
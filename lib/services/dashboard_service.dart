import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  // Pointing to your specific live domain
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/customer';

  Future<Map<String, dynamic>?> getDashboardData(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard.php?customer_id=$customerId'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      print("Error fetching dashboard data: $e");
      return null;
    }
  }

  // --- NEW: Fetch Live Inventory Images ---
  Future<List<Map<String, dynamic>>> getLiveNewArrivals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_new_arrivals.php'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return List<Map<String, dynamic>>.from(decoded['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print("Error fetching new arrivals: $e");
      return [];
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class SchemeService {
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api';

  // ==========================================
  // 1. FETCH AVAILABLE SCHEMES
  // ==========================================
  Future<List<Map<String, dynamic>>> getAvailableSchemes() async {
    try {
      final url = Uri.parse('$baseUrl/customer/schemes.php?action=list_active');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['schemes'] ?? data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // 2. FETCH CUSTOMER ENROLLED SCHEMES
  // ==========================================
  Future<List<Map<String, dynamic>>> getCustomerSchemes(String customerId) async {
    try {
      final url = Uri.parse('$baseUrl/customer/customer_schemes.php?action=my_schemes&user_id=$customerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['customer_schemes'] ?? data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // 3. ENROLL IN SCHEME (NEW!)
  // ==========================================
  Future<Map<String, dynamic>> enrollInScheme({required String customerId, required String schemeId}) async {
    try {
      final url = Uri.parse('$baseUrl/customer/enroll_scheme.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customer_id': customerId, 'scheme_id': schemeId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Server error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==========================================
  // 4. SUBMIT INQUIRY (Kept for Support)
  // ==========================================
  Future<Map<String, dynamic>> submitSchemeInquiry({required String customerId, required String schemeId, required String inquiryType}) async {
    try {
      final url = Uri.parse('$baseUrl/customer/support_tickets.php?action=create_inquiry');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customer_id': customerId, 'scheme_id': schemeId, 'type': inquiryType}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Server error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
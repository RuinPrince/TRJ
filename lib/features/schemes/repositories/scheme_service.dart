import 'dart:convert';
import 'package:http/http.dart' as http;
// Ensure you have your ApiConfig file created as discussed earlier
import '../../../services/api_config.dart';

class SchemeService {
  
  // ==========================================
  // 1. FETCH AVAILABLE SCHEMES (Global Catalog)
  // ==========================================
  Future<List<Map<String, dynamic>>> getAvailableSchemes() async {
    try {
      // Assuming your schemes.php handles an 'action=list_active' GET request
      final url = Uri.parse('${ApiConfig.baseUrl}/schemes.php?action=list_active');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['schemes'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching available schemes: $e');
      return [];
    }
  }

  // ==========================================
  // 2. FETCH CUSTOMER ENROLLED SCHEMES
  // ==========================================
  Future<List<Map<String, dynamic>>> getCustomerSchemes(String customerId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/customer_schemes.php?action=my_schemes&user_id=$customerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['customer_schemes'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching customer schemes: $e');
      return [];
    }
  }

  // ==========================================
  // 3. SUBMIT INQUIRY (Replaces standard Join/Checkout)
  // ==========================================
  Future<Map<String, dynamic>> submitSchemeInquiry({
    required String customerId,
    required String schemeId,
    required String inquiryType, // e.g., 'join_request', 'payment_inquiry'
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/support_tickets.php?action=create_inquiry');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'scheme_id': schemeId,
          'type': inquiryType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'error': 'Server error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
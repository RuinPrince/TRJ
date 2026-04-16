import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/local_storage_service.dart';

class PaymentService {
  final String baseUrl = 'https://trj.dreamyoursinfotech.com/api/customer';

  // ==========================================
  // 1. CREATE CASHFREE ORDER (For Checkout Screen)
  // ==========================================
  // FIXED: Added schemeId parameter
  Future<Map<String, dynamic>> createCashfreeOrder(String customerId, String schemeId, double amount, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_order.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "customer_id": customerId,
          "scheme_id": schemeId, // <-- NOW SENDING TO PHP
          "amount": amount,
          "customer_phone": phone,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"status": "error", "message": "Failed to connect to server"};
    } catch (e) {
      return {"status": "error", "message": "Network error occurred"};
    }
  }

  // ==========================================
  // 2. VERIFY PAYMENT (After Cashfree UI closes)
  // ==========================================
  Future<bool> verifyPaymentStatus(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_payment.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"order_id": orderId}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 3. FETCH PAYMENT HISTORY
  // ==========================================
  Future<List<Map<String, dynamic>>> getPaymentHistory({int limit = 20}) async {
    try {
      // Get the logged-in user ID dynamically from local storage
      final String? userJson = await LocalStorageService().getUserData();
      if (userJson == null) return [];
      final user = jsonDecode(userJson);
      final String userId = user['id'].toString();

      // Call Hostinger API
      final response = await http.get(Uri.parse('$baseUrl/payment_history.php?user_id=$userId&limit=$limit'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') {
          return List<Map<String, dynamic>>.from(decoded['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  // ==========================================
  // 4. GET NEXT PAYMENT DETAILS
  // ==========================================
  Future<Map<String, dynamic>> getNextPaymentDetails(String customerSchemeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/next_payment.php?scheme_id=$customerSchemeId'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded; 
      }
      return {'success': false, 'error': 'Failed to fetch from server'};
    } catch (e) {
      return {'success': false, 'error': 'Network error'};
    }
  }

  // ==========================================
  // 5. GET RECEIPT DETAILS
  // ==========================================
  Future<Map<String, dynamic>?> getReceiptDetails(String transactionId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/receipt.php?transaction_id=$transactionId'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success') return decoded['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
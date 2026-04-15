import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

import '../../../services/payment_service.dart';
import '../../../services/local_storage_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String customerSchemeId;
  final String schemeName;
  final double amount;

  const CheckoutScreen({
    super.key,
    required this.customerSchemeId,
    required this.schemeName,
    required this.amount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  bool _isProcessing = false;
  final CFPaymentGatewayService _cashfreeService = CFPaymentGatewayService();
  final PaymentService _paymentService = PaymentService(); 

  @override
  void initState() {
    super.initState();
    _cashfreeService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) async {
    debugPrint("Payment Success in SDK: $orderId");
    
    // Show a loading indicator while we talk to the server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verifying payment securely...'), duration: Duration(seconds: 2)),
    );

    // Tell Hostinger to verify the order and update the database!
    final bool isVerified = await _paymentService.verifyPaymentStatus(orderId);

    if (mounted) {
      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Verified & Scheme Updated!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification delayed. Check history shortly.'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context, false);
      }
    }
  }

  void onError(CFErrorResponse error, String orderId) {
    final String message = error.getMessage() ?? "";

    debugPrint("Error: $message for Order: $orderId");

    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.isNotEmpty ? message : 'Payment failed'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _initiatePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Fetch real user data from device storage
      final String? userJson = await LocalStorageService().getUserData();
      String customerId = '0';
      String phone = '9999999999';

      if (userJson != null) {
        final user = jsonDecode(userJson);
        customerId = user['id']?.toString() ?? '0';
        phone = user['phone']?.toString() ?? '9999999999';
      }

      // 2. Call your Hostinger create_order.php script
      final result = await _paymentService.createCashfreeOrder(
        customerId,
        widget.amount,
        phone,
      );

      if (result['status'] == 'success') {
        // Extract the real IDs from your backend
        final sessionId = result['payment_session_id'];
        final orderId = result['order_id'];

        // ✅ SESSION
        var sessionBuilder = CFSessionBuilder();
        sessionBuilder.setEnvironment(CFEnvironment.PRODUCTION); // Change to PRODUCTION when live
        sessionBuilder.setOrderId(orderId);
        sessionBuilder.setPaymentSessionId(sessionId);

        final session = sessionBuilder.build();

        // ✅ THEME
        var themeBuilder = CFThemeBuilder();
        themeBuilder.setNavigationBarBackgroundColorColor("#881337");
        themeBuilder.setNavigationBarTextColor("#FFFFFF");
        themeBuilder.setButtonBackgroundColor("#B4941F");
        themeBuilder.setButtonTextColor("#FFFFFF");

        final theme = themeBuilder.build();

        // ✅ DROP CHECKOUT
        var dropBuilder = CFDropCheckoutPaymentBuilder();
        dropBuilder.setSession(session!);
        dropBuilder.setTheme(theme!);

        final payment = dropBuilder.build();

        if (payment != null) {
          _cashfreeService.doPayment(payment);
        } else {
          throw Exception("Payment object null");
        }
      } else {
        throw Exception(result['message'] ?? "Failed to create order on server");
      }
    } catch (e) {
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment init failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Secure Checkout', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.schemeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("₹${widget.amount.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 24, color: primaryRed, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("PAY NOW", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
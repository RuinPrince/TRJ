import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

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

  @override
  void initState() {
    super.initState();
    _cashfreeService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    debugPrint("Payment Success: $orderId");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
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
      final sessionId = await _fetchSessionIdFromBackend();
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

      // ✅ SESSION
      var sessionBuilder = CFSessionBuilder();
      sessionBuilder.setEnvironment(CFEnvironment.SANDBOX);
      sessionBuilder.setOrderId(orderId);
      sessionBuilder.setPaymentSessionId(sessionId);

      final session = sessionBuilder.build();

      // ✅ THEME
      var themeBuilder = CFThemeBuilder();
      themeBuilder.setNavigationBarBackgroundColorColor("#881337"); // FIXED
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

  Future<String> _fetchSessionIdFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    return "session_mock_123456789";
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
                    : const Text("PAY NOW"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
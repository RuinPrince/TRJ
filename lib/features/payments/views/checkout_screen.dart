import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _launchWebPayment() async {
    setState(() => _isProcessing = true);

    try {
      final String? userJson = await LocalStorageService().getUserData();
      if (userJson == null) throw Exception("Not logged in");
      final user = jsonDecode(userJson);
      final String userId = user['id'].toString();

      // THE FIX: Sending User ID, Scheme ID, and Amount to the generator!
      final response = await http.post(
        Uri.parse('https://trj.dreamyoursinfotech.com/api/customer/get_payment_link.php'),
        body: {
          'user_id': userId,
          'customer_scheme_id': widget.customerSchemeId,
          'amount': widget.amount.toString()
        },
      );

      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        final url = Uri.parse(data['url']);
        await launchUrl(url, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          setState(() => _isProcessing = false);
          Navigator.pop(context, true); 
        }
      } else {
         throw Exception(data['message'] ?? "Failed to generate secure link");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')), 
            backgroundColor: Colors.redAccent
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Secure Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.green.shade600, size: 48),
                        const SizedBox(height: 16),
                        const Text("Payment Redirect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          "You will be securely redirected to the Cashfree gateway to complete your installment.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textMuted, height: 1.5),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
                        Text(widget.schemeName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text("₹${widget.amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 32, color: primaryRed, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _launchWebPayment,
                style: ElevatedButton.styleFrom(backgroundColor: primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: _isProcessing ? const SizedBox.shrink() : const Icon(Icons.open_in_browser, color: Colors.white),
                label: _isProcessing
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("PROCEED TO SECURE PAYMENT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
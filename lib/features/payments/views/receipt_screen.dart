import 'package:flutter/material.dart';

class ReceiptScreen extends StatefulWidget {
  final String transactionId;

  const ReceiptScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  bool _isDownloading = false;

  // --- Placeholder Data (Replacing PHP PDO Fetch) ---
  final Map<String, dynamic> _receiptData = {
    'transaction_id': 'TXN20240815A',
    'date': '15 Aug, 2024 • 10:30 AM',
    'customer_name': 'John Doe',
    'customer_phone': '+91 98765 43210',
    'scheme_name': 'Swarna Vruksham',
    'scheme_code': 'SV-2024',
    'payment_method': 'UPI',
    'status': 'COMPLETED',
    'base_amount': 2000.00,
    'gst_amount': 60.00, // 3% GST as per receipt(1).php
    'late_fee': 0.00,
    'total_amount': 2060.00,
  };

  // Company details from your PHP files
  final String companyName = "Thanga Roja Jewellers";
  final String companyAddress = "99 A/4, Sri Vishnu Complex, South Avani Moola St,\nMadurai - 625001";
  final String companyPhone = "+91 98658 42294";
  final String companyEmail = "trjmadurai@gmail.com";

  Future<void> _handleDownloadPdf() async {
    setState(() => _isDownloading = true);
    
    // TODO: Implement PDF Generation here.
    // Option 1: Use the 'pdf' dart package to generate locally.
    // Option 2: Call a Firebase Cloud Function (replacing your old TCPDF PHP script) 
    // to generate the PDF on the server and return a download URL.
    
    await Future.delayed(const Duration(seconds: 2)); // Simulating network/generation time
    
    setState(() => _isDownloading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt downloaded successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Digital Receipt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Red background extension for the top of the card
          Container(
            height: 40,
            width: double.infinity,
            color: primaryRed,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -40), // Pull the receipt up into the red area
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptHeader(),
                      const _DashedDivider(),
                      _buildTransactionInfo(),
                      const _DashedDivider(),
                      _buildCustomerAndSchemeInfo(),
                      const _DashedDivider(),
                      _buildAmountBreakdown(),
                      const _DashedDivider(),
                      _buildFooterSignatures(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _handleDownloadPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isDownloading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text(
                _isDownloading ? 'GENERATING PDF...' : 'DOWNLOAD PDF RECEIPT',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildReceiptHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.diamond_outlined, color: primaryGold, size: 48),
          const SizedBox(height: 12),
          Text(
            companyName.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryRed, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
          ),
          const SizedBox(height: 8),
          Text(
            companyAddress,
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            'Ph: $companyPhone | $companyEmail',
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          
          // Success Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'PAYMENT ${_receiptData['status']}',
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction ID', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_receiptData['transaction_id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              Text('Payment Date', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_receiptData['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Payment Mode', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_receiptData['payment_method'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              Text('Type', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              const Text('Scheme Installment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndSchemeInfo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BILLED TO', style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(_receiptData['customer_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_receiptData['customer_phone'], style: TextStyle(color: textMuted, fontSize: 14)),
          
          const SizedBox(height: 20),
          
          Text('SCHEME DETAILS', style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_receiptData['scheme_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_receiptData['scheme_code'], style: TextStyle(color: textMuted, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildAmountRow('Base Amount', _receiptData['base_amount']),
          const SizedBox(height: 12),
          _buildAmountRow('GST (3%)', _receiptData['gst_amount']),
          const SizedBox(height: 12),
          _buildAmountRow('Late Fee', _receiptData['late_fee']),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, thickness: 1),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '₹${_receiptData['total_amount'].toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 14)),
        Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildFooterSignatures() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, width: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text('Member Acknowledgment', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('Digital Confirmation', style: TextStyle(fontSize: 9, color: textMuted)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(height: 1, width: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text('Authorized Signatory', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(companyName, style: TextStyle(fontSize: 9, color: textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '* This is a computer-generated digital receipt. No physical signature is required for validation. For any discrepancies, please contact the showroom helpdesk within 48 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// A helper widget to draw the dashed lines found on receipts
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 5.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
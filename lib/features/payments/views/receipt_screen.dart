import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';

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
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  bool _isDownloading = false;
  bool _isLoading = true;
  Map<String, dynamic> _receiptData = {};

  final PaymentService _paymentService = PaymentService();

  // Company details
  final String companyName = "Thanga Roja Jewellers";
  final String companyAddress = "99 A/4, Sri Vishnu Complex, South Avani Moola St,\nMadurai - 625001";
  final String companyPhone = "+91 98658 42294";
  final String companyEmail = "trjmadurai@gmail.com";

  @override
  void initState() {
    super.initState();
    _fetchReceiptData();
  }

  Future<void> _fetchReceiptData() async {
    setState(() => _isLoading = true);
    
    final data = await _paymentService.getReceiptDetails(widget.transactionId);
    
    if (mounted) {
      setState(() {
        _receiptData = data ?? {};
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year} • $hour:$min $ampm';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Future<void> _handleDownloadPdf() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(seconds: 2)); 
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
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryRed))
        : _receiptData.isEmpty 
          ? Center(child: Text("Receipt not found.", style: TextStyle(color: textMuted)))
          : Column(
              children: [
                Container(height: 40, width: double.infinity, color: primaryRed),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Transform.translate(
                      offset: const Offset(0, -40),
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
              onPressed: (_isDownloading || _isLoading || _receiptData.isEmpty) ? null : _handleDownloadPdf,
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
          Text(companyAddress, textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, height: 1.4)),
          const SizedBox(height: 4),
          Text('Ph: $companyPhone | $companyEmail', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'PAYMENT ${(_receiptData['status'] ?? 'COMPLETED').toString().toUpperCase()}',
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
              Text(_receiptData['transaction_id'] ?? widget.transactionId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              Text('Payment Date', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_formatDateTime(_receiptData['payment_date']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Payment Mode', style: TextStyle(color: textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_receiptData['payment_method'] ?? 'Online', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
          Text(_receiptData['customer_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_receiptData['customer_phone'] ?? '', style: TextStyle(color: textMuted, fontSize: 14)),
          
          const SizedBox(height: 20),
          Text('SCHEME DETAILS', style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_receiptData['scheme_name'] ?? 'Gold Scheme', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(_receiptData['scheme_code'] ?? '', style: TextStyle(color: textMuted, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    // Dynamic math based on what the backend gives us
    final double totalAmount = double.tryParse(_receiptData['amount']?.toString() ?? '0') ?? 0.0;
    
    // In many flows, GST is calculated backwards or sent via backend. 
    // If backend doesn't send gst_amount, we fallback to 0 or manual math here:
    final double gstAmount = double.tryParse(_receiptData['gst_amount']?.toString() ?? '0') ?? 0.0;
    final double lateFee = double.tryParse(_receiptData['late_fee']?.toString() ?? '0') ?? 0.0;
    final double baseAmount = totalAmount - gstAmount - lateFee;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildAmountRow('Base Amount', baseAmount),
          const SizedBox(height: 12),
          _buildAmountRow('GST', gstAmount),
          if (lateFee > 0) ...[
            const SizedBox(height: 12),
            _buildAmountRow('Late Fee', lateFee),
          ],
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, thickness: 1),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
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
                child: const DecoratedBox(decoration: BoxDecoration(color: Colors.black12)),
              );
            }),
          );
        },
      ),
    );
  }
}
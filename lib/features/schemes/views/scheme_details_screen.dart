import 'package:flutter/material.dart';

class SchemeDetailsScreen extends StatefulWidget {
  // In a real app, you would pass the scheme ID via constructor
  // final String customerSchemeId;
  
  const SchemeDetailsScreen({super.key});

  @override
  State<SchemeDetailsScreen> createState() => _SchemeDetailsScreenState();
}

class _SchemeDetailsScreenState extends State<SchemeDetailsScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  // --- Placeholder Data (Replacing PHP PDO Fetches) ---
  final Map<String, dynamic> _scheme = {
    'id': 'CUS-SCH-101',
    'scheme_name': 'Swarna Vruksham',
    'monthly_amount': 2000.0,
    'paid_months': 8,
    'tenure_months': 11,
    'start_date': '15 Jan, 2024',
    'next_payment_date': '15 Sep, 2024',
    'status': 'active', // can be 'active', 'maturity', 'completed'
    'total_gold_accumulated': 3.45,
    'total_investment': 16000.0,
  };

  final List<Map<String, dynamic>> _transactions = [
    {'tx_id': 'TXN20240815A', 'date': '15 Aug, 2024', 'amount': 2000.0, 'method': 'UPI', 'status': 'completed'},
    {'tx_id': 'TXN20240715B', 'date': '15 Jul, 2024', 'amount': 2000.0, 'method': 'Card', 'status': 'completed'},
    {'tx_id': 'TXN20240615C', 'date': '15 Jun, 2024', 'amount': 2000.0, 'method': 'UPI', 'status': 'completed'},
  ];

  void _handlePayment() {
    // Navigate to Checkout/Payment Screen
    // Navigator.pushNamed(context, '/checkout', arguments: _scheme['id']);
  }

  void _generateReport() {
    // Trigger PDF generation logic (Replicates action=generate_pdf)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF Report...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _scheme['status'] == 'completed';
    final double progress = _scheme['paid_months'] / _scheme['tenure_months'];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scheme Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (Status & Name)
            _buildHeaderCard(isCompleted),
            const SizedBox(height: 16),

            // 2. Progress & Gold Accumulation Card
            _buildProgressCard(progress),
            const SizedBox(height: 16),

            // 3. Key Metrics Grid
            _buildMetricsGrid(),
            const SizedBox(height: 24),

            // 4. Transaction History List
            const Text(
              'Payment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
            ),
            const SizedBox(height: 12),
            _buildTransactionHistory(),
            const SizedBox(height: 80), // Padding for bottom bar
          ],
        ),
      ),
      
      // 5. Contextual Bottom Action Bar
      bottomSheet: _buildBottomActionBar(isCompleted),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildHeaderCard(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _scheme['scheme_name'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
              ),
              const SizedBox(height: 4),
              Text('Started on ${_scheme['start_date']}', style: TextStyle(color: textMuted, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade50 : primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _scheme['status'].toString().toUpperCase(),
              style: TextStyle(
                color: isCompleted ? Colors.green.shade700 : primaryGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryRed, const Color(0xFF6B0F2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: primaryRed.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gold Accumulated', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Icon(Icons.diamond, color: primaryGold, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${_scheme['total_gold_accumulated']} ',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text('Grams', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Installment Progress', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              Text('${_scheme['paid_months']} / ${_scheme['tenure_months']} Months', 
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: primaryGold,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Monthly Amount',
            value: '₹${_scheme['monthly_amount']}',
            icon: Icons.currency_rupee,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            title: 'Total Invested',
            value: '₹${_scheme['total_investment']}',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textMuted, size: 20),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No payments made yet', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            ),
            title: Text(tx['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('ID: ${tx['tx_id']} • ${tx['method']}', style: TextStyle(color: textMuted, fontSize: 11)),
            trailing: Text(
              '₹${tx['amount']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isCompleted) ...[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Due Date', style: TextStyle(color: textMuted, fontSize: 12)),
                    Text(
                      _scheme['next_payment_date'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('PAY NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              // Completed State Actions
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text('DOWNLOAD FINAL REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  String _selectedFilter = 'All';

  // --- Placeholder Data (Replacing PHP PDO Fetches) ---
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'tx_id': 'TXN20240815A',
      'scheme_name': 'Swarna Vruksham',
      'date': '15 Aug, 2024',
      'time': '10:30 AM',
      'amount': 2000.0,
      'method': 'UPI',
      'status': 'completed',
    },
    {
      'tx_id': 'TXN20240715B',
      'scheme_name': 'Swarna Vruksham',
      'date': '15 Jul, 2024',
      'time': '02:15 PM',
      'amount': 2000.0,
      'method': 'Credit Card',
      'status': 'completed',
    },
    {
      'tx_id': 'TXN20240615C',
      'scheme_name': 'Thanga Magal',
      'date': '15 Jun, 2024',
      'time': '11:45 AM',
      'amount': 5000.0,
      'method': 'Net Banking',
      'status': 'failed',
    },
    {
      'tx_id': 'TXN20240515D',
      'scheme_name': 'Swarna Vruksham',
      'date': '15 May, 2024',
      'time': '09:00 AM',
      'amount': 2000.0,
      'method': 'Auto-Debit',
      'status': 'pending',
    },
  ];

  // Logic to filter transactions based on selected chip
  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _allTransactions;
    return _allTransactions
        .where((tx) => tx['status'].toString().toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  void _downloadReceipt(String transactionId) {
    // In Flutter, we will navigate to the Receipt Screen and pass the ID
    // Navigator.pushNamed(context, '/receipt', arguments: transactionId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening receipt for $transactionId...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(
        children: [
          // 1. Filter Chips (Translating the status filter from customer_payments.php)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Completed'),
                  _buildFilterChip('Pending'),
                  _buildFilterChip('Failed'),
                ],
              ),
            ),
          ),
          
          // 2. Transaction List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _filteredTransactions[index];
                      return _buildTransactionCard(tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: primaryGold,
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: isSelected ? primaryGold : Colors.grey.shade300),
        onSelected: (bool selected) {
          if (selected) {
            setState(() => _selectedFilter = label);
          }
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final bool isCompleted = tx['status'] == 'completed';
    final bool isFailed = tx['status'] == 'failed';
    final bool isPending = tx['status'] == 'pending';

    // Determine icon and colors based on status
    IconData statusIcon = Icons.check_circle;
    Color statusColor = Colors.green;
    Color bgColor = Colors.green.shade50;

    if (isFailed) {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
      bgColor = Colors.red.shade50;
    } else if (isPending) {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
      bgColor = Colors.orange.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row: Icon, Scheme Name, Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['scheme_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tx['date']} • ${tx['time']}',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${tx['amount'].toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx['status'].toString().toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            
            // Bottom Row: Details & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ref: ${tx['tx_id']}', style: TextStyle(color: textMuted, fontSize: 11)),
                    Text('Via ${tx['method']}', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
                if (isCompleted)
                  OutlinedButton.icon(
                    onPressed: () => _downloadReceipt(tx['tx_id']),
                    icon: Icon(Icons.receipt_long, size: 16, color: primaryGold),
                    label: Text('Receipt', style: TextStyle(color: primaryGold, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryGold.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                if (isFailed)
                  TextButton(
                    onPressed: () {
                      // Navigate to retry payment
                    },
                    child: const Text('Retry', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no ${_selectedFilter.toLowerCase()} payments.',
            style: TextStyle(color: textMuted),
          ),
        ],
      ),
    );
  }
}
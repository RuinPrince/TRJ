import 'package:flutter/material.dart';
import '../../../services/payment_service.dart';
import '../../../services/scheme_service.dart';
import '../../../services/api_config.dart';
import '../../../services/auth_service.dart'; // Needed for logout

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);

  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  List<Map<String, dynamic>> _mySchemes = [];
  List<Map<String, dynamic>> _allTransactions = [];

  final PaymentService _paymentService = PaymentService();
  final SchemeService _schemeService = SchemeService();

  @override
  void initState() {
    super.initState();
    _loadAllPaymentData();
  }

  Future<void> _loadAllPaymentData() async {
    setState(() => _isLoading = true);
    final String? loggedInUserId = ApiConfig.currentUserId; 

    final results = await Future.wait([
      _paymentService.getPaymentHistory(),
      if (loggedInUserId != null) _schemeService.getCustomerSchemes(loggedInUserId) else Future.value([]),
    ]);

    if (mounted) {
      setState(() {
        _allTransactions = results[0] as List<Map<String, dynamic>>;
        if (results.length > 1) {
          _mySchemes = results[1] as List<Map<String, dynamic>>;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (e) {
      return dateTimeStr.split(' ').first;
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    } catch (e) {
      final parts = dateTimeStr.split(' ');
      return parts.length > 1 ? parts[1] : '';
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _allTransactions;
    return _allTransactions.where((tx) => (tx['status'] ?? '').toString().toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('Payment History', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            indicatorColor: primaryGold,
            indicatorWeight: 3,
            labelColor: primaryRed,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [Tab(text: 'MAKE PAYMENT'), Tab(text: 'PAYMENT HISTORY')],
          ),
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : TabBarView(children: [_buildMakePaymentTab(), _buildPaymentHistoryTab()]),
          
        // --- ADDED FOOTER NAVIGATION ---
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: BottomNavigationBar(
            currentIndex: 2, // THE FIX: Hardcoded to Pay!
            onTap: (index) {
              if (index == 2) return; // Already on Pay
              if (index == 4) {
                _handleLogout();
                return;
              }
              // Clear the stack safely when going home
              if (index == 0) {
                Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
                return;
              }
              String route = index == 1 ? '/schemes' : '/profile';
              Navigator.pushReplacementNamed(context, route);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryRed,
            unselectedItemColor: textMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
              BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), activeIcon: Icon(Icons.diamond), label: 'SCHEMES'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'PAY'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
              BottomNavigationBarItem(icon: Icon(Icons.logout, color: Colors.redAccent), activeIcon: Icon(Icons.logout), label: 'LOGOUT'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMakePaymentTab() {
    final pendingPayments = _mySchemes.where((s) => s['status'] == 'active').toList();
    if (pendingPayments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diamond_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 24),
              const Text('No Active Schemes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Text("You don't have any pending installments.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingPayments.length,
      itemBuilder: (context, index) {
        final scheme = pendingPayments[index];
        final double amount = double.tryParse(scheme['monthly_amount'].toString()) ?? 0.0;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: const Color(0xFFFFF6F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(scheme['scheme_name'] ?? 'Scheme', style: TextStyle(fontSize: 18, color: textDark, fontWeight: FontWeight.bold)),
                    Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryRed)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Due Date: ${scheme['next_payment_date'] ?? 'N/A'}', style: TextStyle(color: textMuted, fontSize: 14)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout', arguments: {'customerSchemeId': scheme['id'].toString(), 'schemeName': scheme['scheme_name'], 'amount': amount})
                        .then((_) => _loadAllPaymentData());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('PAY NOW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistoryTab() {
    return Column(
      children: [
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
        
        Expanded(
          child: _filteredTransactions.isEmpty
              ? Center(child: Text('No transactions found.', style: TextStyle(color: textMuted)))
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
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : textMuted, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
        ),
        selected: isSelected,
        showCheckmark: isSelected,
        checkmarkColor: Colors.white,
        selectedColor: primaryGold,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), 
          side: BorderSide(color: isSelected ? primaryGold : Colors.grey.shade300)
        ),
        onSelected: (bool selected) {
          if (selected) setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final statusStr = (tx['status'] ?? 'pending').toString().toLowerCase();
    final bool isCompleted = statusStr == 'completed';
    final bool isFailed = statusStr == 'failed';
    final bool isPending = statusStr == 'pending';

    final double amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
    final String schemeName = tx['scheme_name'] ?? 'Gold Scheme';
    final String transactionId = tx['transaction_id'] ?? 'N/A';
    final String method = tx['payment_method'] ?? 'Online';
    final String dateStr = _formatDate(tx['payment_date']);
    final String timeStr = _formatTime(tx['payment_date']);

    IconData statusIcon = Icons.check_circle;
    Color statusColor = Colors.green.shade600;
    Color bgColor = Colors.green.shade50;

    if (isFailed) {
      statusIcon = Icons.cancel;
      statusColor = Colors.red.shade600;
      bgColor = Colors.red.shade50;
    } else if (isPending) {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange.shade600;
      bgColor = Colors.orange.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(statusIcon, color: statusColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schemeName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      const SizedBox(height: 4),
                      Text('$dateStr • $timeStr', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                    const SizedBox(height: 4),
                    Text(statusStr.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ref: $transactionId', style: TextStyle(color: textMuted, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('Via $method', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
                
                if (isCompleted)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/receipt', arguments: transactionId),
                    icon: Icon(Icons.receipt_long, size: 14, color: primaryGold),
                    label: Text('Receipt', style: TextStyle(color: primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryGold, width: 1.0), 
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                      minimumSize: const Size(0, 36)
                    ),
                  ),
                
                if (isFailed)
                  TextButton(
                    onPressed: () => DefaultTabController.of(context).animateTo(0),
                    child: const Text('Retry', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
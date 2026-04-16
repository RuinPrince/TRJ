import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/dashboard_service.dart'; 
import '../../../services/auth_service.dart'; 
import '../../../services/local_storage_service.dart';
import '../../../services/scheme_service.dart'; 
import '../../../services/payment_service.dart'; 

import 'new_arrivals_widget.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color deepBlack = const Color(0xFF0F172A);

  bool _isLoading = true;

  String userName = "Loading...";
  String userId = "TRJ-....";
  
  double totalInvestment = 0.0;
  int activeSchemesCount = 0;
  double goldRate = 0.0;
  double silverRate = 0.0;

  List<Map<String, dynamic>> activeSchemes = [];
  List<Map<String, dynamic>> recentPayments = [];
  List<Map<String, dynamic>> newArrivals = []; 

  final DashboardService _dashboardService = DashboardService();
  final SchemeService _schemeService = SchemeService();
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _fetchLiveDashboardData();
  }

  Future<void> _fetchLiveDashboardData() async {
    setState(() => _isLoading = true);

    final String? userJson = await LocalStorageService().getUserData();
    if (userJson == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    final user = jsonDecode(userJson);
    final String currentUserId = user['id'].toString(); 
    
    final results = await Future.wait([
      _dashboardService.getDashboardData(currentUserId),
      _schemeService.getCustomerSchemes(currentUserId),
      _paymentService.getPaymentHistory(limit: 3),
      _dashboardService.getLiveNewArrivals(), 
    ]);
    
    final dashboardData = results[0] as Map<String, dynamic>?;
    final userSchemes = results[1] as List<Map<String, dynamic>>;
    final userPayments = results[2] as List<Map<String, dynamic>>;
    final liveArrivals = results[3] as List<Map<String, dynamic>>;

    if (mounted) {
      setState(() {
        userName = dashboardData?['user']?['full_name'] ?? user['full_name'] ?? 'Customer';
        userId = "TRJ-${dashboardData?['user']?['id'] ?? currentUserId}";
        
        totalInvestment = double.tryParse(dashboardData?['stats']?['total_investment']?.toString() ?? '0') ?? 0.0;
        
        activeSchemes = userSchemes.where((s) => s['status'] == 'active').toList();
        activeSchemesCount = activeSchemes.length;
        
        goldRate = double.tryParse(dashboardData?['rates']?['gold_22k']?.toString() ?? '0') ?? 0.0;
        silverRate = double.tryParse(dashboardData?['rates']?['silver']?.toString() ?? '0') ?? 0.0;
        
        recentPayments = userPayments;
        newArrivals = liveArrivals; 
        
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        toolbarHeight: 65, 
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRed, primaryGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/trj.png', 
              height: 45, 
              width: 45,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language switcher coming soon')));
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
            ),
            child: const Text('தமிழ்', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Text(
                userName.length >= 2 ? userName.substring(0, 2).toUpperCase() : 'C',
                style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryRed))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketRates(),
                const SizedBox(height: 24),
                if (newArrivals.isNotEmpty) ...[
                  NewArrivalsWidget(items: newArrivals),
                  const SizedBox(height: 20),
                ],
                _buildAccountSummary(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildSectionHeader('My Active Schemes', 'Add Scheme', () {
                  Navigator.pushNamed(context, '/schemes');
                }),
                _buildActiveSchemes(),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Payments', 'View All', () {
                  Navigator.pushNamed(context, '/payment-history');
                }),
                _buildRecentPayments(),
                const SizedBox(height: 20),
              ],
            ),
          ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // THE FIX: Hardcoded to Home!
          onTap: (index) {
            if (index == 0) return; // Already on Home
            if (index == 4) {
              _handleLogout();
              return;
            }
            // THE FIX: Do not use setState here. Just push the screen!
            switch (index) {
              case 1: Navigator.pushNamed(context, '/schemes'); break;
              case 2: Navigator.pushNamed(context, '/payment-history'); break;
              case 3: Navigator.pushNamed(context, '/profile'); break;
            }
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
    );
  }

  Widget _buildMarketRates() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFFB4941F), width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GOLD 22K', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown.shade700)),
                    const Icon(Icons.circle, color: Colors.green, size: 8), 
                  ],
                ),
                const SizedBox(height: 4),
                Text('₹$goldRate', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Per gram', style: TextStyle(fontSize: 10, color: Colors.brown.shade400)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFF64748B), width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SILVER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                    const Icon(Icons.circle, color: Colors.green, size: 8), 
                  ],
                ),
                const SizedBox(height: 4),
                Text('₹$silverRate', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Per gram', style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade400)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.badge_outlined, color: primaryRed, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('ID: $userId', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL INVESTMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 4),
                    Text('₹$totalInvestment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryRed)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(Icons.diamond, color: primaryGold, size: 14),
                      const SizedBox(width: 4),
                      Text('$activeSchemesCount Active', style: TextStyle(color: primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionBtn(Icons.currency_rupee, 'Pay Now', Colors.red, () {
          Navigator.pushNamed(context, '/schemes');
        }),
        _buildActionBtn(Icons.receipt_long, 'Receipts', Colors.orange, () {
          Navigator.pushNamed(context, '/payment-history');
        }),
        _buildActionBtn(Icons.support_agent, 'Support', Colors.blue, () {
          Navigator.pushNamed(context, '/support');
        }),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel, style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildActiveSchemes() {
    if (activeSchemes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('No active schemes found.', style: TextStyle(color: textMuted)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeSchemes.length,
      itemBuilder: (context, index) {
        final scheme = activeSchemes[index];
        
        final String schemeName = scheme['scheme_name'] ?? 'Unknown Scheme';
        final double amount = double.tryParse(scheme['monthly_amount']?.toString() ?? '0') ?? 0.0;
        final int paidMonths = int.tryParse(scheme['paid_months']?.toString() ?? '0') ?? 0;
        final int tenureMonths = int.tryParse(scheme['tenure_months']?.toString() ?? '1') ?? 1;
        final String nextPaymentDate = scheme['next_payment_date'] ?? 'N/A';
        final String status = scheme['status'] ?? 'Active';
        
        final double progress = (paidMonths / tenureMonths).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schemeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Playfair Display')),
                      Text('₹$amount / Month', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(status.toUpperCase(), style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: primaryGold,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(progress * 100).toInt()}% Progress', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                  Text('$paidMonths/$tenureMonths Months', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: primaryRed, size: 14),
                      const SizedBox(width: 4),
                      Text('Next: $nextPaymentDate', style: TextStyle(fontSize: 12, color: textMuted)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout', arguments: {
                        'customerSchemeId': scheme['id'].toString(),
                        'schemeName': schemeName,
                        'amount': amount,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentPayments() {
    if (recentPayments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('No recent payments.', style: TextStyle(color: textMuted))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentPayments.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = recentPayments[index];
          
          final String schemeName = payment['scheme_name'] ?? 'Payment';
          final double amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
          final String dateStr = payment['payment_date'] != null ? payment['payment_date'].toString().split(' ')[0] : 'N/A';
          final String status = payment['status'] ?? 'completed';
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(schemeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(dateStr, style: TextStyle(color: textMuted, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text(status.toUpperCase(), style: TextStyle(fontSize: 9, color: textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
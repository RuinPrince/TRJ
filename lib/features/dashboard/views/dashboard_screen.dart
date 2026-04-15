import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/dashboard_service.dart'; 
import '../../../services/auth_service.dart'; 
import '../../../services/local_storage_service.dart'; // ADDED: For dynamic user ID

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color deepBlack = const Color(0xFF0F172A);

  int _currentIndex = 0; // For Bottom Navigation
  bool _isLoading = true;

  // --- Dynamic User Data Variables ---
  String userName = "Loading...";
  String userId = "TRJ-....";
  
  double totalInvestment = 0.0;
  int activeSchemesCount = 0;
  double goldRate = 0.0;
  double silverRate = 0.0;

  List<Map<String, dynamic>> activeSchemes = [];
  List<Map<String, dynamic>> recentPayments = [];

  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _fetchLiveDashboardData();
  }

  Future<void> _fetchLiveDashboardData() async {
    setState(() => _isLoading = true);

    // 1. Get the REAL logged-in user dynamically from device storage
    final String? userJson = await LocalStorageService().getUserData();
    if (userJson == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    final user = jsonDecode(userJson);
    final String currentUserId = user['id'].toString(); 
    
    // 2. Fetch the live data from your Hostinger dashboard.php
    final dashboardData = await _dashboardService.getDashboardData(currentUserId);
    
    if (dashboardData != null && mounted) {
      setState(() {
        // Map the PHP JSON response to the Flutter state variables
        userName = dashboardData['user']?['full_name'] ?? user['full_name'] ?? 'Customer';
        userId = "TRJ-${dashboardData['user']?['id'] ?? currentUserId}";
        
        totalInvestment = double.tryParse(dashboardData['stats']?['total_investment']?.toString() ?? '0') ?? 0.0;
        activeSchemesCount = int.tryParse(dashboardData['stats']?['active_count']?.toString() ?? '0') ?? 0;
        
        // This will now correctly populate with the live PHP database values!
        goldRate = double.tryParse(dashboardData['rates']?['gold_22k']?.toString() ?? '0') ?? 0.0;
        silverRate = double.tryParse(dashboardData['rates']?['silver']?.toString() ?? '0') ?? 0.0;
        
        if (dashboardData['active_schemes'] != null) {
          activeSchemes = List<Map<String, dynamic>>.from(dashboardData['active_schemes']);
        }
        if (dashboardData['recent_payments'] != null) {
          recentPayments = List<Map<String, dynamic>>.from(dashboardData['recent_payments']);
        }
      });
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Handle Logout
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

      // --- TOP APP BAR ---
      appBar: AppBar(
        automaticallyImplyLeading: false, 
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
              'assets/images/trj.png', // Ensure this path matches your asset
              height: 50, 
              width: 50,
              // Optional: If your logo is a solid shape and you want it completely white 
              // against the gradient, uncomment the line below:
              // color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair Display',
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher
          TextButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language switcher coming soon')),
              );
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
          // User Avatar
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
      
      // --- MAIN CONTENT ---
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryRed))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Market Rates
                _buildMarketRates(),
                const SizedBox(height: 20),

                // 2. Account Summary Card
                _buildAccountSummary(),
                const SizedBox(height: 20),

                // 3. Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 24),

                // 4. Active Schemes
                _buildSectionHeader('My Active Schemes', 'Add Scheme', () {
                  Navigator.pushNamed(context, '/schemes');
                }),
                _buildActiveSchemes(),
                const SizedBox(height: 24),

                // 5. Recent Payments
                _buildSectionHeader('Recent Payments', 'View All', () {
                  Navigator.pushNamed(context, '/payment-history');
                }),
                _buildRecentPayments(),
                const SizedBox(height: 20),
              ],
            ),
          ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Intercept logout index (4) before setting state
            if (index == 4) {
              _handleLogout();
              return;
            }
            
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                break; // Already on Dashboard
              case 1:
                Navigator.pushNamed(context, '/schemes');
                break;
              case 2:
                Navigator.pushNamed(context, '/payment-history');
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
                break;
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

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildMarketRates() {
    return Row(
      children: [
        // Gold Rate
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
                    const Icon(Icons.circle, color: Colors.green, size: 8), // Live indicator
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
        // Silver Rate
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
                    const Icon(Icons.circle, color: Colors.green, size: 8), // Live indicator
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
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
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
        final double amount = double.tryParse(scheme['amount']?.toString() ?? '0') ?? 0.0;
        final int paidMonths = int.tryParse(scheme['paid_months']?.toString() ?? '0') ?? 0;
        final int tenureMonths = int.tryParse(scheme['tenure_months']?.toString() ?? '1') ?? 1;
        
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
                      Text(scheme['name'] ?? 'Unknown Scheme', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Playfair Display')),
                      Text('₹$amount / Month', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(scheme['status'] ?? 'Active', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      Text('Next: ${scheme['next_payment'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: textMuted)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout', arguments: {
                        'customerSchemeId': scheme['id'] ?? 'SCHEME_ID_$index',
                        'schemeName': scheme['name'] ?? '',
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
          final double amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(payment['name'] ?? 'Payment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(payment['date'] ?? '', style: TextStyle(color: textMuted, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text((payment['status'] ?? 'Completed').toString().toUpperCase(), style: TextStyle(fontSize: 9, color: textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
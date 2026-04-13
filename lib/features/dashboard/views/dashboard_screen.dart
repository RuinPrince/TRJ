import 'package:flutter/material.dart';
import 'sidebar_menu.dart'; // Make sure this points to your actual sidebar file!

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

  // --- Placeholder Data (Replace with real data from Firestore/State Management) ---
  final String userName = "John Doe";
  final String userId = "TRJ-00124";
  final double totalInvestment = 24500.00;
  final int activeSchemesCount = 2;
  final double goldRate = 6540.00;
  final double silverRate = 78.50;

  final List<Map<String, dynamic>> activeSchemes = [
    {
      'name': 'Swarna Vruksham',
      'amount': 2000.0,
      'paid_months': 5,
      'tenure_months': 11,
      'next_payment': '15 May, 2024',
      'status': 'Active'
    },
  ];

  final List<Map<String, dynamic>> recentPayments = [
    {'name': 'Swarna Vruksham', 'date': '15 Apr, 2024', 'amount': 2000.0, 'status': 'Completed'},
    {'name': 'Thanga Magal', 'date': '10 Mar, 2024', 'amount': 1500.0, 'status': 'Completed'},
  ];
  // ---------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softWhite,
      
      drawer: const SidebarMenu(currentRoute: '/dashboard'), 

      // --- TOP APP BAR ---
      appBar: AppBar(
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
            Icon(Icons.diamond_outlined, color: Colors.white, size: 28),
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
                userName.substring(0, 2).toUpperCase(),
                style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      // --- MAIN CONTENT ---
      body: SingleChildScrollView(
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
        final double progress = scheme['paid_months'] / scheme['tenure_months'];

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
                      Text(scheme['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Playfair Display')),
                      Text('₹${scheme['amount']} / Month', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(scheme['status'], style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
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
                  Text('${scheme['paid_months']}/${scheme['tenure_months']} Months', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted)),
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
                      Text('Next: ${scheme['next_payment']}', style: TextStyle(fontSize: 12, color: textMuted)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout', arguments: {
                        'customerSchemeId': 'SCHEME_ID_$index',
                        'schemeName': scheme['name'],
                        'amount': scheme['amount'],
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
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(payment['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(payment['date'], style: TextStyle(color: textMuted, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${payment['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text(payment['status'].toUpperCase(), style: TextStyle(fontSize: 9, color: textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
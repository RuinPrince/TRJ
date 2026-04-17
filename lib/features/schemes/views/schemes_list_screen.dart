import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/scheme_service.dart'; 
import '../../../services/local_storage_service.dart'; // THE FIX: Use local storage directly
import '../../../services/auth_service.dart';

class SchemesListScreen extends StatefulWidget {
  const SchemesListScreen({super.key});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen> {
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color cardPinkBg = const Color(0xFFFFF6F6); 
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);

  bool _isLoading = true;
  List<Map<String, dynamic>> _availableSchemes = [];
  List<Map<String, dynamic>> _mySchemes = [];

  final SchemeService _schemeService = SchemeService();

  @override
  void initState() {
    super.initState();
    _loadSchemesData();
  }

  // ==========================================
  // THE FIX: Fetch real-time ID from Local Storage
  // ==========================================
  Future<void> _loadSchemesData() async {
    setState(() => _isLoading = true);
    
    // Safely get the absolute current user from device memory
    final String? userJson = await LocalStorageService().getUserData();
    String? loggedInUserId;
    
    if (userJson != null) {
      final user = jsonDecode(userJson);
      loggedInUserId = user['id'].toString();
    }

    final results = await Future.wait([
      _schemeService.getAvailableSchemes(),
      if (loggedInUserId != null) _schemeService.getCustomerSchemes(loggedInUserId) else Future.value([]),
    ]);

    if (mounted) {
      setState(() {
        if (results.length > 1) {
          _mySchemes = results[1] as List<Map<String, dynamic>>;
        }
        
        final enrolledNames = _mySchemes.map((s) => s['scheme_name']).toSet();
        final allAvailable = results[0] as List<Map<String, dynamic>>;
        
        _availableSchemes = allAvailable
            .where((scheme) => !enrolledNames.contains(scheme['scheme_name']))
            .toList();
            
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

  void _showEnrollmentModal(Map<String, dynamic> scheme) {
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Confirm Enrollment', style: TextStyle(fontSize: 22, color: primaryRed, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('You are about to start a new legacy with ${scheme['scheme_name']}.', style: TextStyle(color: textMuted, fontSize: 14)),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardPinkBg, 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: Colors.red.shade50),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly Commitment', style: TextStyle(color: textMuted, fontSize: 15)),
                          Text('₹${scheme['monthly_amount']}', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Tenure', style: TextStyle(color: textMuted, fontSize: 15)),
                          Text('${scheme['tenure_months']} Months', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: Colors.grey.shade300)
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          setModalState(() => isSubmitting = true);
                          
                          // THE FIX: Get exact ID at the moment of enrollment
                          final String? userJson = await LocalStorageService().getUserData();
                          String currentUserId = '0';
                          if (userJson != null) {
                             final user = jsonDecode(userJson);
                             currentUserId = user['id'].toString();
                          }

                          final response = await _schemeService.enrollInScheme(
                            customerId: currentUserId,
                            schemeId: scheme['id'].toString(),
                          );

                          if (mounted) {
                            Navigator.pop(context); 
                            if (response['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment Successful!'), backgroundColor: Colors.green));
                              _loadSchemesData(); 
                              DefaultTabController.of(context).animateTo(1); 
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Enrollment failed'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isSubmitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('JOIN SCHEME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
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
          title: Row(
            children: [
              Icon(Icons.diamond_outlined, color: primaryGold),
              const SizedBox(width: 8),
              const Text('Gold Schemes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: TabBar(
            indicatorColor: primaryGold,
            indicatorWeight: 3,
            labelColor: primaryRed,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [Tab(text: 'AVAILABLE SCHEMES'), Tab(text: 'MY SCHEMES')],
          ),
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : TabBarView(children: [_buildAvailableSchemesTab(), _buildMySchemesTab()]),
          
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              if (index == 1) return;
              if (index == 4) {
                _handleLogout();
                return;
              }
              if (index == 0) {
                Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
                return;
              }
              String route = index == 2 ? '/payment-history' : '/profile';
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

  Widget _buildAvailableSchemesTab() {
    if (_availableSchemes.isEmpty) return Center(child: Text('No schemes available.', style: TextStyle(color: textMuted)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _availableSchemes[index];
        final String schemeType = (scheme['scheme_type'] ?? 'MONTHLY').toString().toUpperCase();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: cardPinkBg,
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
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2D9), 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(schemeType, style: TextStyle(color: primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MONTHLY AMOUNT', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('₹${scheme['monthly_amount'] ?? 0}', style: TextStyle(fontSize: 18, color: primaryRed, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TENURE', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('${scheme['tenure_months'] ?? 0} Months', style: TextStyle(fontSize: 16, color: textDark, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(scheme['description'] ?? 'Save monthly and get 100% off on making charges at maturity.', style: TextStyle(color: textMuted, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showEnrollmentModal(scheme),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryGold, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('JOIN SCHEME', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGold, letterSpacing: 1.0)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMySchemesTab() {
    if (_mySchemes.isEmpty) return Center(child: Text('You haven\'t joined any schemes yet.', style: TextStyle(color: textMuted)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySchemes.length,
      itemBuilder: (context, index) {
        final scheme = _mySchemes[index];
        final int paidMonths = int.tryParse(scheme['paid_months']?.toString() ?? '0') ?? 0;
        final int tenureMonths = int.tryParse(scheme['tenure_months']?.toString() ?? '1') ?? 1;
        final double progress = (paidMonths / tenureMonths).clamp(0.0, 1.0);
        final String status = (scheme['status'] ?? 'Active').toString().toUpperCase();
        final double amount = double.tryParse(scheme['monthly_amount'].toString()) ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: cardPinkBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/scheme-details', arguments: scheme['id']),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(scheme['scheme_name'] ?? 'Scheme', style: TextStyle(fontSize: 18, color: textDark, fontWeight: FontWeight.bold)),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA), 
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(status, style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.grey.shade300, 
                    color: primaryGold, 
                    minHeight: 8, 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toInt()}% Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                      Text('$paidMonths of $tenureMonths Months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                    ],
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: textMuted),
                              const SizedBox(width: 4),
                              Text('Next Due', style: TextStyle(fontSize: 10, color: textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(scheme['next_payment_date'] ?? 'N/A', style: TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/checkout',
                            arguments: {
                              'customerSchemeId': scheme['id'].toString(), 
                              'schemeName': scheme['scheme_name'],
                              'amount': amount,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('PAY ₹${amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
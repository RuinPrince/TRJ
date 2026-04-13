import 'package:flutter/material.dart';

class SchemesListScreen extends StatefulWidget {
  const SchemesListScreen({super.key});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  // --- Placeholder Data (Replace with Firebase/Provider Data) ---
  final List<Map<String, dynamic>> _availableSchemes = [
    {
      'id': 'SCH-001',
      'scheme_name': 'Swarna Vruksham',
      'scheme_type': 'monthly',
      'monthly_amount': 2000.0,
      'tenure_months': 11,
      'description': 'Save monthly and get 100% off on making charges at maturity.',
    },
    {
      'id': 'SCH-002',
      'scheme_name': 'Thanga Magal',
      'scheme_type': 'flexible',
      'monthly_amount': 5000.0,
      'tenure_months': 11,
      'description': 'Flexible daily/weekly savings converted to gold weight.',
    },
  ];

  final List<Map<String, dynamic>> _mySchemes = [
    {
      'id': 'CUS-SCH-101',
      'scheme_name': 'Swarna Vruksham',
      'monthly_amount': 2000.0,
      'paid_months': 5,
      'tenure_months': 11,
      'next_payment_date': '15 May, 2024',
      'status': 'Active',
      'total_gold_accumulated': '1.5',
    },
  ];

  // ==========================================
  // JOIN SCHEME BOTTOM SHEET
  // ==========================================
  void _showJoinSchemeModal(Map<String, dynamic> scheme) {
    bool autoDebit = false;

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
                    const Text(
                      'Join Scheme',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scheme['scheme_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly Amount', style: TextStyle(color: textMuted)),
                          Text('₹${scheme['monthly_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tenure', style: TextStyle(color: textMuted)),
                          Text('${scheme['tenure_months']} Months', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: autoDebit,
                      activeColor: primaryGold,
                      onChanged: (val) => setModalState(() => autoDebit = val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Set up Auto-Debit for future installments',
                        style: TextStyle(color: textMuted, fontSize: 14),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Connect to SchemeService to join scheme
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully joined ${scheme['scheme_name']}!'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CONFIRM & JOIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
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
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Icon(Icons.diamond_outlined, color: primaryGold),
              const SizedBox(width: 8),
              const Text(
                'Gold Schemes',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: primaryGold,
            indicatorWeight: 3,
            labelColor: primaryRed,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'AVAILABLE SCHEMES'),
              Tab(text: 'MY SCHEMES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailableSchemesTab(),
            _buildMySchemesTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: AVAILABLE SCHEMES
  // ==========================================
  Widget _buildAvailableSchemesTab() {
    if (_availableSchemes.isEmpty) {
      return const Center(child: Text('No schemes available at the moment.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _availableSchemes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scheme['scheme_name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        scheme['scheme_type'].toString().toUpperCase(),
                        style: TextStyle(color: primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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
                          Text('MONTHLY AMOUNT', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                          Text('₹${scheme['monthly_amount']}', style: TextStyle(fontSize: 18, color: primaryRed, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TENURE', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                          Text('${scheme['tenure_months']} Months', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(scheme['description'], style: TextStyle(color: textMuted, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showJoinSchemeModal(scheme),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGold,
                      side: BorderSide(color: primaryGold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('JOIN SCHEME', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: MY SCHEMES (ENROLLED)
  // ==========================================
  Widget _buildMySchemesTab() {
    if (_mySchemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('You haven\'t joined any schemes yet.', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySchemes.length,
      itemBuilder: (context, index) {
        final scheme = _mySchemes[index];
        final double progress = scheme['paid_months'] / scheme['tenure_months'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to scheme details screen
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        scheme['scheme_name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          scheme['status'].toString().toUpperCase(),
                          style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar Section
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: primaryGold,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toInt()}% Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                      Text('${scheme['paid_months']} of ${scheme['tenure_months']} Months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                    ],
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  
                  // Bottom Metrics & Pay Button
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
                              Text('Next Due', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(scheme['next_payment_date'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to Checkout Screen and pass the specific scheme details
                          Navigator.pushNamed(
                            context, 
                            '/checkout', 
                            arguments: {
                              'customerSchemeId': scheme['id'], // e.g. 'CUS-SCH-101'
                              'schemeName': scheme['scheme_name'],
                              'amount': scheme['monthly_amount'], // Ensure this is a double
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('PAY ₹2000', style: TextStyle(fontWeight: FontWeight.bold)),
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
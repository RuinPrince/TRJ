import 'package:flutter/material.dart';
import '../../../services/scheme_service.dart'; // <-- FIXED IMPORT PATH
import '../../../services/api_config.dart';

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

  bool _isLoading = true;
  List<Map<String, dynamic>> _availableSchemes = [];
  List<Map<String, dynamic>> _mySchemes = [];

  final SchemeService _schemeService = SchemeService();

  @override
  void initState() {
    super.initState();
    _loadSchemesData();
  }

  Future<void> _loadSchemesData() async {
    setState(() => _isLoading = true);

    final String? loggedInUserId = ApiConfig.currentUserId; 

    // Run both API calls concurrently for faster loading
    final results = await Future.wait([
      _schemeService.getAvailableSchemes(),
      if (loggedInUserId != null) _schemeService.getCustomerSchemes(loggedInUserId) else Future.value([]),
    ]);

    if (mounted) {
      setState(() {
        _availableSchemes = results[0] as List<Map<String, dynamic>>;
        if (results.length > 1) {
          _mySchemes = results[1] as List<Map<String, dynamic>>;
        }
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // INQUIRY BOTTOM SHEET (Replaces Checkout/Cart)
  // ==========================================
  void _showInquiryModal(Map<String, dynamic> scheme, String inquiryType) {
    bool _isSubmitting = false;
    final bool isJoinRequest = inquiryType == 'join_request';

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
                    Text(
                      isJoinRequest ? 'Join Scheme Inquiry' : 'Payment Inquiry',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
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
                      Text(scheme['scheme_name'] ?? 'Scheme', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly Amount', style: TextStyle(color: textMuted)),
                          Text('₹${scheme['monthly_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isJoinRequest 
                    ? 'Our team will contact you shortly to process your enrollment and provide payment details.'
                    : 'Request payment details or notify us about a recent transfer for this scheme.',
                  style: TextStyle(color: textMuted, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () async {
                      setModalState(() => _isSubmitting = true);
                      
                      final response = await _schemeService.submitSchemeInquiry(
                        customerId: ApiConfig.currentUserId ?? '0',
                        schemeId: scheme['id'].toString(),
                        inquiryType: inquiryType,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['success'] == true 
                              ? 'Inquiry sent successfully! We will contact you soon.' 
                              : 'Failed to send inquiry. Please try again.'),
                            backgroundColor: response['success'] == true ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SUBMIT INQUIRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : TabBarView(
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
                      scheme['scheme_name'] ?? 'Scheme',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        (scheme['scheme_type'] ?? 'Standard').toString().toUpperCase(),
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
                          Text('₹${scheme['monthly_amount'] ?? 0}', style: TextStyle(fontSize: 18, color: primaryRed, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TENURE', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                          Text('${scheme['tenure_months'] ?? 0} Months', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(scheme['description'] ?? 'Join our exclusive gold scheme.', style: TextStyle(color: textMuted, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showInquiryModal(scheme, 'join_request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGold,
                      side: BorderSide(color: primaryGold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('INQUIRE TO JOIN', style: TextStyle(fontWeight: FontWeight.bold)),
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
        final int paidMonths = int.tryParse(scheme['paid_months']?.toString() ?? '0') ?? 0;
        final int tenureMonths = int.tryParse(scheme['tenure_months']?.toString() ?? '1') ?? 1;
        final double progress = (paidMonths / tenureMonths).clamp(0.0, 1.0);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/scheme-details', arguments: scheme['id']);
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
                        scheme['scheme_name'] ?? 'Scheme',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          (scheme['status'] ?? 'Active').toString().toUpperCase(),
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
                      Text('$paidMonths of $tenureMonths Months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                    ],
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  
                  // Bottom Metrics & Inquire Button
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
                          Text(scheme['next_payment_date'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showInquiryModal(scheme, 'payment_inquiry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('CONTACT TO PAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
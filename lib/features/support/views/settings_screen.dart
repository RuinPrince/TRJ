import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  bool _isLoading = false;

  // --- Controllers for Manual Rate Override ---
  final TextEditingController _goldRateController = TextEditingController(text: '6540.00');
  final TextEditingController _silverRateController = TextEditingController(text: '78.50');

  // --- Controllers for System Preferences ---
  final TextEditingController _appNameController = TextEditingController(text: 'Thanga Roja Jewellers');
  final TextEditingController _supportEmailController = TextEditingController(text: 'trjmadurai@gmail.com');
  final TextEditingController _supportPhoneController = TextEditingController(text: '+91 98658 42294');
  final TextEditingController _makingChargesController = TextEditingController(text: '3.00');
  final TextEditingController _gstController = TextEditingController(text: '3.00');

  // --- Placeholder Data for Rate History ---
  final List<Map<String, dynamic>> _rateHistory = [
    {'date': '2024-04-10', 'gold': 6540.00, 'silver': 78.50, 'source': 'Auto Scrape'},
    {'date': '2024-04-09', 'gold': 6520.00, 'silver': 78.00, 'source': 'Auto Scrape'},
    {'date': '2024-04-08', 'gold': 6500.00, 'silver': 77.80, 'source': 'Manual'},
  ];

  @override
  void dispose() {
    _goldRateController.dispose();
    _silverRateController.dispose();
    _appNameController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _makingChargesController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _handleSave(String section) async {
    setState(() => _isLoading = true);
    
    // TODO: Connect to SettingsService to update Firestore or Backend
    await Future.delayed(const Duration(seconds: 1)); 
    
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$section updated successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  void _handleBackup() async {
    // Replicates your PHP backupDatabase() logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating Database Backup...'), backgroundColor: Colors.blue),
    );
    // TODO: Trigger Cloud Function to generate SQL/JSON dump and return download link
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'System Settings',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
          ),
          bottom: TabBar(
            indicatorColor: primaryGold,
            indicatorWeight: 3,
            labelColor: primaryRed,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(text: 'LIVE RATES'),
              Tab(text: 'PREFERENCES'),
              Tab(text: 'MAINTENANCE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRatesTab(),
            _buildPreferencesTab(),
            _buildMaintenanceTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: GOLD & SILVER RATES
  // ==========================================
  Widget _buildRatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Auto Scrape Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryGold.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: primaryGold.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Automated Market Rates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Icon(Icons.auto_graph, color: primaryGold),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Fetch the latest market rates automatically. This replaces the manual override.', style: TextStyle(color: textMuted, fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSave('Rates Fetched'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.sync),
                    label: const Text('FETCH LATEST RATES NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Manual Override Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manual Rate Override', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Gold 22K Rate (₹)', _goldRateController, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Silver Rate (₹)', _silverRateController, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _handleSave('Manual Rates'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryRed,
                      side: BorderSide(color: primaryRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('APPLY MANUAL OVERRIDE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Rate History Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rate History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Playfair Display')),
              TextButton.icon(
                onPressed: () {
                  // Replicates downloadRateHistory() from PHP
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...')));
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export CSV'),
                style: TextButton.styleFrom(foregroundColor: primaryGold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Gold 22K', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Silver', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _rateHistory.map((rate) {
                  return DataRow(cells: [
                    DataCell(Text(rate['date'])),
                    DataCell(Text('₹${rate['gold']}', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold))),
                    DataCell(Text('₹${rate['silver']}')),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rate['source'] == 'Auto Scrape' ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(rate['source'], style: TextStyle(
                        color: rate['source'] == 'Auto Scrape' ? Colors.green.shade700 : Colors.orange.shade700,
                        fontSize: 10, fontWeight: FontWeight.bold
                      )),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: SYSTEM PREFERENCES
  // ==========================================
  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('General Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFB4941F))),
            const SizedBox(height: 16),
            _buildTextField('Application Name', _appNameController),
            _buildTextField('Support Email Address', _supportEmailController, keyboardType: TextInputType.emailAddress),
            _buildTextField('Support Phone Number', _supportPhoneController, keyboardType: TextInputType.phone),
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            
            const Text('Tax & Charges Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFB4941F))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Making Charges (%)', _makingChargesController, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('GST Percentage (%)', _gstController, isNumber: true)),
              ],
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handleSave('System Preferences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE PREFERENCES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: MAINTENANCE & BACKUP
  // ==========================================
  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Backup Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.storage, color: Colors.blue.shade700, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Database Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Download a complete SQL/JSON dump of your database including users, schemes, and payments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('DOWNLOAD BACKUP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade700)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Clearing the system cache will force all active users to fetch fresh data from the server. This may temporarily increase server load.', style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // Replicates $cacheManager->clear() logic
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System Cache Cleared!')));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700),
                  ),
                  child: const Text('Clear System Cache'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : (keyboardType ?? TextInputType.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGold)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
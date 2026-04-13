import 'package:flutter/material.dart';

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  // --- Placeholder Data for Logs (Replacing system_logs.php fetch) ---
  String _selectedLogType = 'All';
  final List<Map<String, dynamic>> _systemLogs = [
    {
      'id': 1042,
      'user': 'Admin User',
      'action': 'Updated Gold Rate',
      'details': 'Changed from ₹6500 to ₹6540 manually.',
      'type': 'system',
      'ip': '192.168.1.105',
      'date': '10 Apr, 2024 • 14:30',
    },
    {
      'id': 1041,
      'user': 'John Doe',
      'action': 'Customer Login',
      'details': 'Successful login via mobile app.',
      'type': 'auth',
      'ip': '10.0.0.42',
      'date': '10 Apr, 2024 • 09:15',
    },
    {
      'id': 1040,
      'user': 'System',
      'action': 'Automated Backup',
      'details': 'Database backup generated successfully.',
      'type': 'system',
      'ip': 'localhost',
      'date': '10 Apr, 2024 • 02:00',
    },
  ];

  // --- Placeholder Data for Reports (Replacing reportss.php fetch) ---
  final Map<String, dynamic> _metrics = {
    'total_customers': 1245,
    'active_schemes': 850,
    'total_investment': 12500000.00,
    'monthly_revenue': 1450000.00,
  };

  // ==========================================
  // GENERATE REPORT BOTTOM SHEET (reportss.php)
  // ==========================================
  void _showGenerateReportModal() {
    String selectedReport = 'customer';
    String selectedFormat = 'pdf';

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
                      'Generate Custom Report',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text('REPORT TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedReport,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Customer Activity Report')),
                    DropdownMenuItem(value: 'scheme', child: Text('Scheme Performance Report')),
                    DropdownMenuItem(value: 'payment', child: Text('Payment & Revenue Report')),
                  ],
                  onChanged: (val) => setModalState(() => selectedReport = val!),
                ),
                const SizedBox(height: 16),

                const Text('EXPORT FORMAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedFormat,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF Document (.pdf)')),
                    DropdownMenuItem(value: 'csv', child: Text('CSV Spreadsheet (.csv)')),
                    DropdownMenuItem(value: 'excel', child: Text('Excel Document (.xlsx)')),
                  ],
                  onChanged: (val) => setModalState(() => selectedFormat = val!),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generating $selectedFormat report...'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('DOWNLOAD REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: bgLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'System Analytics & Logs',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
          ),
          bottom: TabBar(
            indicatorColor: primaryGold,
            indicatorWeight: 3,
            labelColor: primaryRed,
            unselectedLabelColor: textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(text: 'REPORTS & METRICS'),
              Tab(text: 'SYSTEM AUDIT LOGS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportsTab(),
            _buildLogsTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: REPORTS & ANALYTICS (reportss.php)
  // ==========================================
  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Grid
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Customers', _metrics['total_customers'].toString(), Icons.people_alt, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Active Schemes', _metrics['active_schemes'].toString(), Icons.diamond, primaryGold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Total Investment', '₹${(_metrics['total_investment'] / 100000).toStringAsFixed(2)}L', Icons.account_balance, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Monthly Revenue', '₹${(_metrics['monthly_revenue'] / 100000).toStringAsFixed(2)}L', Icons.trending_up, primaryRed)),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Placeholder (In a real app, use fl_chart package here)
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text('Revenue Trend Chart', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
                Text('(Requires fl_chart package)', style: TextStyle(color: textMuted, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generate Report Action
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: _showGenerateReportModal,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryRed,
                side: BorderSide(color: primaryRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERATE CUSTOM REPORT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: SYSTEM LOGS (system_logs.php)
  // ==========================================
  Widget _buildLogsTab() {
    return Column(
      children: [
        // Filter Bar & Clear Logs Action
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Filter Dropdown
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLogType,
                    style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                    icon: Icon(Icons.keyboard_arrow_down, color: textMuted, size: 16),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Modules')),
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'auth', child: Text('Authentication')),
                      DropdownMenuItem(value: 'payment', child: Text('Payments')),
                    ],
                    onChanged: (val) => setState(() => _selectedLogType = val!),
                  ),
                ),
              ),
              
              // Clear Logs Button
              TextButton.icon(
                onPressed: () {
                  // Translating the JS Confirm Dialog from system_logs.php
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear System Logs?'),
                      content: const Text('Are you sure you want to clear the logs? This action cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Clear Logs', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Clear Logs', style: TextStyle(color: Colors.red, fontSize: 13)),
              )
            ],
          ),
        ),
        
        // Logs List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _systemLogs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final log = _systemLogs[index];
              
              // Filter logic
              if (_selectedLogType != 'All' && log['type'] != _selectedLogType) {
                return const SizedBox.shrink();
              }

              IconData icon = Icons.info_outline;
              Color iconBg = Colors.grey.shade100;
              Color iconColor = Colors.grey.shade600;

              if (log['type'] == 'auth') {
                icon = Icons.lock_outline;
                iconBg = Colors.blue.shade50;
                iconColor = Colors.blue.shade700;
              } else if (log['type'] == 'system') {
                icon = Icons.settings;
                iconBg = Colors.purple.shade50;
                iconColor = Colors.purple.shade700;
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(log['action'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(log['date'], style: TextStyle(color: textMuted, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(log['details'], style: TextStyle(color: textMuted, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, size: 12, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(log['user'], style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                              const SizedBox(width: 16),
                              Icon(Icons.computer, size: 12, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(log['ip'], style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
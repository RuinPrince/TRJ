import 'package:flutter/material.dart';

class AdminSchemesScreen extends StatefulWidget {
  const AdminSchemesScreen({super.key});

  @override
  State<AdminSchemesScreen> createState() => _AdminSchemesScreenState();
}

class _AdminSchemesScreenState extends State<AdminSchemesScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  // --- Placeholder Data (Replacing PHP PDO Fetch) ---
  final List<Map<String, dynamic>> _schemes = [
    {
      'id': 1,
      'scheme_name': 'Swarna Vruksham',
      'scheme_type': 'monthly',
      'monthly_amount': 2000.0,
      'tenure_months': 11,
      'status': 'active',
      'active_customers': 45,
    },
    {
      'id': 2,
      'scheme_name': 'Thanga Magal',
      'scheme_type': 'flexible',
      'monthly_amount': 5000.0,
      'tenure_months': 11,
      'status': 'active',
      'active_customers': 120,
    },
    {
      'id': 3,
      'scheme_name': 'Festival Special',
      'scheme_type': 'daily',
      'monthly_amount': 100.0,
      'tenure_months': 12,
      'status': 'archived',
      'active_customers': 0,
    },
  ];

  // ==========================================
  // ADD / EDIT SCHEME BOTTOM SHEET (Replaces PHP Modals)
  // ==========================================
  void _showSchemeForm({Map<String, dynamic>? scheme}) {
    final bool isEditing = scheme != null;
    
    // Controllers for the form
    final nameController = TextEditingController(text: scheme?['scheme_name'] ?? '');
    final amountController = TextEditingController(text: scheme?['monthly_amount']?.toString() ?? '');
    final tenureController = TextEditingController(text: scheme?['tenure_months']?.toString() ?? '');
    String selectedType = scheme?['scheme_type'] ?? 'monthly';
    String selectedStatus = scheme?['status'] ?? 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Modal Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Scheme' : 'Add New Scheme',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Scheme Name', 'e.g., Swarna Vruksham', nameController),
                        const SizedBox(height: 16),
                        
                        // Scheme Type Dropdown
                        const Text('SCHEME TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedType,
                              items: const [
                                DropdownMenuItem(value: 'monthly', child: Text('Monthly Fixed')),
                                DropdownMenuItem(value: 'flexible', child: Text('Flexible Amount')),
                                DropdownMenuItem(value: 'daily', child: Text('Daily Savings')),
                              ],
                              onChanged: (val) => setModalState(() => selectedType = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Amount (₹)', '0.00', amountController, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Tenure (Months)', '11', tenureController, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Status Dropdown
                        const Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedStatus,
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active (Visible to customers)')),
                                DropdownMenuItem(value: 'archived', child: Text('Archived (Hidden)')),
                              ],
                              onChanged: (val) => setModalState(() => selectedStatus = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Submit Button
                Padding(
                  padding: EdgeInsets.only(
                    left: 20, 
                    right: 20, 
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
                    top: 20
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Call SchemeService to save/update data
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isEditing ? 'UPDATE SCHEME' : 'SAVE SCHEME',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGold)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _handleArchive(int schemeId) {
    // Translating the logic from your PHP 'delete' action checking for active customers
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Scheme?'),
        content: const Text('Are you sure you want to archive this scheme? Customers will no longer be able to join it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Check if scheme has active customers via SchemeService, then archive
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
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
        title: const Text(
          'Scheme Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSchemeForm(),
        backgroundColor: primaryGold,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Scheme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _schemes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No schemes found', style: TextStyle(fontSize: 18, color: textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schemes.length,
              itemBuilder: (context, index) {
                final scheme = _schemes[index];
                final isActive = scheme['status'] == 'active';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Title and Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        scheme['scheme_name'],
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          scheme['scheme_type'].toString().toUpperCase(),
                                          style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Archived',
                                style: TextStyle(
                                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Row 2: Metrics
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AMOUNT', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                                  Text('₹${scheme['monthly_amount']}', style: TextStyle(fontSize: 16, color: primaryRed, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TENURE', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                                  Text('${scheme['tenure_months']} Months', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CUSTOMERS', style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                                  Text('${scheme['active_customers']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                        
                        // Row 3: Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showSchemeForm(scheme: scheme),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit'),
                              style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                            ),
                            if (isActive)
                              TextButton.icon(
                                onPressed: () => _handleArchive(scheme['id']),
                                icon: const Icon(Icons.archive_outlined, size: 18),
                                label: const Text('Archive'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
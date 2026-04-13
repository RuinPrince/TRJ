import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  // --- Placeholder Data (Replacing PHP PDO Fetches) ---
  final List<Map<String, dynamic>> _activeTickets = [
    {
      'ticket_number': 'TICKET-20240410-A1B2C3',
      'subject': 'Payment deduction but receipt not generated',
      'category': 'Payment Issue',
      'priority': 'High',
      'status': 'Open',
      'created_at': '10 Apr, 2024',
    },
    {
      'ticket_number': 'TICKET-20240408-X9Y8Z7',
      'subject': 'How to change my address?',
      'category': 'Account Update',
      'priority': 'Low',
      'status': 'In Progress',
      'created_at': '08 Apr, 2024',
    },
  ];

  final List<Map<String, dynamic>> _resolvedTickets = [
    {
      'ticket_number': 'TICKET-20240315-QWERTY',
      'subject': 'Scheme maturity details',
      'category': 'Scheme Inquiry',
      'priority': 'Medium',
      'status': 'Resolved',
      'created_at': '15 Mar, 2024',
    },
  ];

  // ==========================================
  // NEW TICKET BOTTOM SHEET
  // ==========================================
  void _showNewTicketModal() {
    final _formKey = GlobalKey<FormState>();
    final _subjectController = TextEditingController();
    final _messageController = TextEditingController();
    String _selectedCategory = 'General Inquiry';
    String _selectedPriority = 'Low';
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Support Ticket',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextFieldLabel('Subject'),
                          TextFormField(
                            controller: _subjectController,
                            decoration: _inputDecoration('Brief summary of your issue'),
                            validator: (val) => val!.isEmpty ? 'Subject is required' : null,
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextFieldLabel('Category'),
                                    DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      decoration: _inputDecoration(''),
                                      items: const [
                                        DropdownMenuItem(value: 'Payment Issue', child: Text('Payment Issue')),
                                        DropdownMenuItem(value: 'Scheme Inquiry', child: Text('Scheme Inquiry')),
                                        DropdownMenuItem(value: 'Account Update', child: Text('Account Update')),
                                        DropdownMenuItem(value: 'Technical Problem', child: Text('Technical Problem')),
                                        DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry')),
                                      ],
                                      onChanged: (val) => setModalState(() => _selectedCategory = val!),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextFieldLabel('Priority'),
                                    DropdownButtonFormField<String>(
                                      value: _selectedPriority,
                                      decoration: _inputDecoration(''),
                                      items: const [
                                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                        DropdownMenuItem(value: 'High', child: Text('High')),
                                      ],
                                      onChanged: (val) => setModalState(() => _selectedPriority = val!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTextFieldLabel('Message'),
                              Text(
                                '${_messageController.text.length}/2000 chars', // Translating your JS char counter
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _messageController.text.length > 1800 ? Colors.red : textMuted,
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _messageController,
                            maxLines: 6,
                            maxLength: 2000,
                            onChanged: (val) => setModalState(() {}), // Trigger rebuild for char counter
                            decoration: _inputDecoration('Please describe your issue in detail...').copyWith(
                              counterText: '', // Hide default counter to use our custom one
                            ),
                            validator: (val) => val!.isEmpty ? 'Message is required' : null,
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting 
                                ? null 
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      setModalState(() => _isSubmitting = true);
                                      // TODO: Call SupportService to submit to DB
                                      Future.delayed(const Duration(seconds: 2), () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Ticket created successfully!'), backgroundColor: Colors.green),
                                        );
                                      });
                                    }
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isSubmitting 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('SUBMIT TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: bgLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGold)),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
    );
  }

  // ==========================================
  // UI BUILDER
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'ACTIVE TICKETS'),
              Tab(text: 'RESOLVED'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showNewTicketModal,
          backgroundColor: primaryGold,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: TabBarView(
          children: [
            _buildTicketList(_activeTickets),
            _buildTicketList(_resolvedTickets),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.headset_mic_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No tickets found', style: TextStyle(color: textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final bool isOpen = ticket['status'] == 'Open';
        final bool isResolved = ticket['status'] == 'Resolved';

        Color statusColor = Colors.orange; // In Progress default
        if (isOpen) statusColor = Colors.blue;
        if (isResolved) statusColor = Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket chat feature coming soon!'))
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket['ticket_number'],
                        style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['status'],
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket['subject'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category_outlined, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Text(ticket['category'], style: TextStyle(color: textMuted, fontSize: 12)),
                        ],
                      ),
                      Text(ticket['created_at'], style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
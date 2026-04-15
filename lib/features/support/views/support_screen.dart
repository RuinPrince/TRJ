import 'package:flutter/material.dart';
import '../../../services/support_service.dart';
import '../../../services/api_config.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textMuted = const Color(0xFF64748B);

  bool _isLoading = true;
  List<Map<String, dynamic>> _activeTickets = [];
  List<Map<String, dynamic>> _resolvedTickets = [];

  final SupportService _supportService = SupportService();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = ApiConfig.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final allTickets = await _supportService.getTickets(userId);

    if (mounted) {
      setState(() {
        // Split tickets based on status
        _activeTickets = allTickets.where((t) => 
          t['status'] != 'Resolved' && t['status'] != 'Closed'
        ).toList();
        
        _resolvedTickets = allTickets.where((t) => 
          t['status'] == 'Resolved' || t['status'] == 'Closed'
        ).toList();
        
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (e) {
      return dateTimeStr.split(' ').first;
    }
  }

  void _showNewTicketModal() {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = 'General Inquiry';
    String selectedPriority = 'Low';
    bool isSubmitting = false;

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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Support Ticket',
                        style: TextStyle(
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
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextFieldLabel('Subject'),
                          TextFormField(
                            controller: subjectController,
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
                                      isExpanded: true, // Prevents overflow
                                      value: selectedCategory,
                                      decoration: _inputDecoration(''),
                                      items: const [
                                        DropdownMenuItem(value: 'Payment Issue', child: Text('Payment Issue', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Scheme Inquiry', child: Text('Scheme Inquiry', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Account Update', child: Text('Account Update', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Technical Problem', child: Text('Technical Problem', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'General Inquiry', child: Text('General Inquiry', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        setModalState(() {
                                          selectedCategory = val!;
                                        });
                                      },
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
                                      isExpanded: true, // Prevents overflow
                                      value: selectedPriority,
                                      decoration: _inputDecoration(''),
                                      items: const [
                                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                        DropdownMenuItem(value: 'High', child: Text('High')),
                                      ],
                                      onChanged: (val) {
                                        setModalState(() {
                                          selectedPriority = val!;
                                        });
                                      },
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
                                '${messageController.text.length}/2000 chars',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: messageController.text.length > 1800 ? Colors.red : textMuted,
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: messageController,
                            maxLines: 6,
                            maxLength: 2000,
                            onChanged: (val) {
                              setModalState(() {}); 
                            },
                            decoration: _inputDecoration('Please describe your issue in detail...').copyWith(
                              counterText: '', 
                            ),
                            validator: (val) => val!.isEmpty ? 'Message is required' : null,
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isSubmitting 
                                ? null 
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setModalState(() {
                                        isSubmitting = true;
                                      });
                                      
                                      final response = await _supportService.createTicket({
                                        'customer_id': ApiConfig.currentUserId ?? '0',
                                        'subject': subjectController.text,
                                        'category': selectedCategory,
                                        'priority': selectedPriority,
                                        'message': messageController.text,
                                      });

                                      if (mounted) {
                                        Navigator.pop(context);
                                        if (response['success'] == true) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ticket created successfully!'), backgroundColor: Colors.green),
                                          );
                                          _loadTickets(); // Refresh list
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? 'Failed to create ticket'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    }
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: isSubmitting 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(
                                    'SUBMIT TICKET', 
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), 
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), 
        borderSide: BorderSide(color: primaryGold),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label, 
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: textMuted,
        ),
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
          backgroundColor: primaryRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Help & Support', 
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'Playfair Display',
            ),
          ),
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
          label: const Text(
            'New Ticket', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : TabBarView(
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
        final bool isResolved = ticket['status'] == 'Resolved' || ticket['status'] == 'Closed';

        Color statusColor = Colors.orange; // In Progress default
        if (isOpen) statusColor = Colors.blue;
        if (isResolved) statusColor = Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: const Color(0xFFFFF6F6), // Using your pale pink background here too
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket chat feature coming soon!'))
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket['ticket_number'] ?? 'N/A',
                        style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['status'] ?? 'Unknown',
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket['subject'] ?? 'No Subject',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category_outlined, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Text(ticket['category'] ?? 'General', style: TextStyle(color: textMuted, fontSize: 12)),
                        ],
                      ),
                      Text(
                        _formatDate(ticket['created_at']), 
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
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
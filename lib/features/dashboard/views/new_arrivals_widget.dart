import 'package:flutter/material.dart';

class NewArrivalsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const NewArrivalsWidget({
    super.key,
    required this.items,
  });

  // Brand Colors
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color textMuted = const Color(0xFF64748B);

  // Helper method to trigger WhatsApp (requires url_launcher package)
  void _launchWhatsApp(String phone, String itemName, String weight) {
    // Clean phone number
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+', '');
    final message = "Hello, I'm interested in this gold item:\nModel: $itemName\nWeight: $weight grams";
    
    // final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    // launchUrl(url, mode: LaunchMode.externalApplication);
    
    debugPrint('Launching WhatsApp for $itemName to $cleanPhone');
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    // This replicates the Bootstrap Modal from your PHP code
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Image.network(
                item['image_url'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
              ),
            ),
            
            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRODUCT DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Weight', '${item['weight']} Grams', isBold: true),
                    _buildDetailRow('Availability', 'In Stock', valueColor: Colors.green),
                    _buildDetailRow('Valid Until', item['expires_at'], valueColor: primaryRed),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] ?? 'No description available.',
                      style: TextStyle(color: textMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            
            // WhatsApp Button Footer
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchWhatsApp(item['phone'], item['name'], item['weight']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    'GET BEST PRICE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: isBold || valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.diamond_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'No New Arrivals',
              style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for exclusive gold items.',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Arrivals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/schemes');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: primaryRed, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Horizontal Scrollable List
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                
                return GestureDetector(
                  onTap: () => _showItemDetails(context, item),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Portion
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: Image.network(
                                    item['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                        Icon(Icons.image, color: Colors.grey.shade300),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${item['weight']}g',
                                      style: TextStyle(color: primaryRed, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Text Portion
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ends: ${item['expires_at']}',
                                style: TextStyle(fontSize: 10, color: textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
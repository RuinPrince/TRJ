import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SidebarMenu extends StatelessWidget {
  final String currentRoute;
  final String adminName;

 const SidebarMenu({
  super.key,
  this.currentRoute = '', // Now it's optional with a default empty string
  this.adminName = 'Administrator',
});

  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color deepBlack = const Color(0xFF0F172A);
  final Color textMuted = const Color(0xFF94A3B8);

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // Helper method to build navigation links cleanly
  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    final bool isActive = currentRoute == routeName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Close the drawer
          Navigator.pop(context);
          // Navigate only if we aren't already on this screen
          if (!isActive) {
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: isActive
                ? Border(left: BorderSide(color: primaryGold, width: 4))
                : const Border(left: BorderSide(color: Colors.transparent, width: 4)),
            color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? primaryGold : textMuted,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : textMuted,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: deepBlack,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Sidebar Header (Brand Logo)
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.diamond_outlined, color: primaryGold, size: 48),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      children: [
                        const TextSpan(text: 'THANGA ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'ROJA\n', style: TextStyle(color: primaryGold)),
                        const TextSpan(text: 'JEWELLERS', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(color: Colors.white.withOpacity(0.1), height: 1),

            // 2. Navigation Links (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      _buildNavItem(
                        context: context,
                        title: 'Dashboard',
                        icon: Icons.speed,
                        routeName: '/admin/dashboard',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Scheme Management',
                        icon: Icons.diamond,
                        routeName: '/admin/schemes',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Customer Management',
                        icon: Icons.people_alt,
                        routeName: '/admin/customers',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Payment Tracking',
                        icon: Icons.currency_rupee,
                        routeName: '/admin/payments',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Scheme Completion',
                        icon: Icons.task_alt,
                        routeName: '/admin/completions',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Support',
                        icon: Icons.headset_mic,
                        routeName: '/admin/support',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'New Arrivals',
                        icon: Icons.star,
                        routeName: '/admin/new_arrivals',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'System Settings',
                        icon: Icons.settings,
                        routeName: '/admin/settings',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'System Logs',
                        icon: Icons.list_alt,
                        routeName: '/admin/logs',
                      ),
                      _buildNavItem(
                        context: context,
                        title: 'Broadcast Center',
                        icon: Icons.campaign,
                        routeName: '/admin/broadcast',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. User Profile Footer
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primaryGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Secure Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      label: const Text(
                        'Secure Logout',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
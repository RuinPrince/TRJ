import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Brand Colors mapped from PHP CSS
  final Color primaryRed = const Color(0xFF881337);
  final Color primaryGold = const Color(0xFFB4941F);
  final Color softWhite = const Color(0xFFFDFCFB);
  final Color textMuted = const Color(0xFF64748B);
  final Color bgLight = const Color(0xFFF8FAFC);

  // Form Keys
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // --- Profile Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  // --- Password Controllers ---
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- Placeholder Data (Replacing PHP session/DB fetch) ---
  void _loadUserData() {
    // In reality, you'd fetch this from ProfileService/Provider
    _nameController.text = "John Doe";
    _emailController.text = "john@example.com";
    _phoneController.text = "+91 98765 43210";
    _dobController.text = "1990-05-15";
    _addressController.text = "123 Main Street, Anna Nagar";
    _cityController.text = "Madurai";
    _pincodeController.text = "625020";
    _aadharController.text = "1234 5678 9012";
    _panController.text = "ABCDE1234F";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleUpdateProfile() {
    if (_profileFormKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      // TODO: Connect to ProfileService to update Firestore
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
        }
      });
    }
  }

  void _handleChangePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      // TODO: Connect to AuthService to update Firebase Password
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
          );
        }
      });
    }
  }

  // Date Picker Helper
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryRed, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
          title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
        ),
        body: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: primaryRed,
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: primaryGold,
                        child: Text(
                          _nameController.text.isNotEmpty ? _nameController.text.substring(0, 2).toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt, size: 16, color: primaryRed),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(_emailController.text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: primaryGold,
                indicatorWeight: 3,
                labelColor: primaryRed,
                unselectedLabelColor: textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.person_outline), text: 'PERSONAL DETAILS'),
                  Tab(icon: Icon(Icons.security_outlined), text: 'SECURITY'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildProfileTab(),
                  _buildSecurityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: PERSONAL DETAILS FORM
  // ==========================================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _profileFormKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
              _buildTextField(label: 'Email Address', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildTextField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(label: 'Date of Birth', controller: _dobController, icon: Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Address Details'),
              _buildTextField(label: 'Complete Address', controller: _addressController, icon: Icons.home_outlined, maxLines: 2),
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'City', controller: _cityController, icon: Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: 'Pincode', controller: _pincodeController, icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Identity Details (Optional)'),
              _buildTextField(label: 'Aadhar Number', controller: _aadharController, icon: Icons.credit_card, isRequired: false),
              _buildTextField(label: 'PAN Number', controller: _panController, icon: Icons.credit_card_outlined, isRequired: false),

              const SizedBox(height: 24),
              _buildSubmitButton(label: 'UPDATE PROFILE', isProcessing: _isSaving, onPressed: _handleUpdateProfile),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: SECURITY (CHANGE PASSWORD)
  // ==========================================
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _passwordFormKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryGold),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Use a strong password combining letters, numbers, and symbols.', style: TextStyle(color: primaryGold, fontSize: 12))),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildPasswordField(
                label: 'Current Password', 
                controller: _currentPasswordController, 
                obscureText: _obscureCurrent, 
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent)
              ),
              _buildPasswordField(
                label: 'New Password', 
                controller: _newPasswordController, 
                obscureText: _obscureNew, 
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                isNewPassword: true,
              ),
              _buildPasswordField(
                label: 'Confirm New Password', 
                controller: _confirmPasswordController, 
                obscureText: _obscureConfirm, 
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                matchController: _newPasswordController,
              ),

              const SizedBox(height: 24),
              _buildSubmitButton(label: 'CHANGE PASSWORD', isProcessing: _isSaving, onPressed: _handleChangePassword),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon, 
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted),
              children: [
                if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              filled: true,
              fillColor: bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGold)),
            ),
            validator: isRequired ? (value) => value!.isEmpty ? 'This field is required' : null : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    bool isNewPassword = false,
    TextEditingController? matchController,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: bgLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryGold)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (isNewPassword && value.length < 6) return 'Must be at least 6 characters';
              if (matchController != null && value != matchController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({required String label, required bool isProcessing, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isProcessing
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }
}
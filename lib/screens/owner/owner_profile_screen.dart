import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/owner/owner_top_nav_bar.dart';
import '../../widgets/property/property_form_components.dart';

class OwnerProfileScreen extends StatefulWidget {
  final bool showAppBar;
  const OwnerProfileScreen({super.key, this.showAppBar = true});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessPermitController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController =
        TextEditingController(text: user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: user?.lastName ?? '');
    _emailController =
        TextEditingController(text: user?.email ?? '');
    _phoneController =
        TextEditingController(text: user?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: user?.address ?? '');
    _businessNameController =
        TextEditingController(text: user?.businessName ?? '');
    _businessPermitController =
        TextEditingController(text: user?.businessPermitNo ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    _businessPermitController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessPermitNo: _businessPermitController.text.trim(),
        displayName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: isDesktop ? 40 : 20,
                right: isDesktop ? 40 : 20,
                top: 32,
                bottom: isDesktop ? 32 : 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildOwnerInfoSection(),
                        const SizedBox(height: 32),
                        _buildBusinessInfoSection(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );

        if (!widget.showAppBar) return content;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: isDesktop
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(72),
                  child: OwnerTopNavBar(currentRoute: 'Profile'),
                )
              : AppBar(
                  title: const Text('My Profile'),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                ),
          body: content,
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    final user = context.watch<AuthProvider>().user;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final initials = _getInitials(
        user?.displayName ?? 'Owner');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'User Name',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Property Owner',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User Name',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Property Owner',
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        color:
                            Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (user?.businessName != null &&
                        user!.businessName!.isNotEmpty)
                      Text(
                        user.businessName!,
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          color:
                              Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildOwnerInfoSection() {
    final isMobile =
        MediaQuery.of(context).size.width < 600;
    return _buildFormCard(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Owner Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(
                _isSaving ? 'Saving...' : 'Save Changes',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (isMobile) ...[
          PremiumTextField(
            controller: _firstNameController,
            label: 'First Name',
            hintText: 'Enter first name',
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _lastNameController,
            label: 'Last Name',
            hintText: 'Enter last name',
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hintText: 'Enter first name',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hintText: 'Enter last name',
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        if (isMobile) ...[
          PremiumTextField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'email@example.com',
            readOnly: true,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hintText: '09123456789',
            icon: Icons.phone_outlined,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'email@example.com',
                  readOnly: true,
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: '09123456789',
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        PremiumTextField(
          controller: _addressController,
          label: 'Address',
          hintText: 'Enter your business address',
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    final isMobile =
        MediaQuery.of(context).size.width < 600;
    return _buildFormCard(
      children: [
        Row(
          children: [
            Icon(Icons.business_outlined,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Business Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (isMobile) ...[
          PremiumTextField(
            controller: _businessNameController,
            label: 'Business Name',
            hintText: 'Enter business name',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 20),
          PremiumTextField(
            controller: _businessPermitController,
            label: 'Business Permit No.',
            hintText: 'BP-202X-XXXXX',
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: PremiumTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  hintText: 'Enter business name',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  controller: _businessPermitController,
                  label: 'Business Permit No.',
                  hintText: 'BP-202X-XXXXX',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFormCard(
      {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(
              color: AppColors.primary, width: 3),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty
        ? name[0].toUpperCase()
        : 'O';
  }
}

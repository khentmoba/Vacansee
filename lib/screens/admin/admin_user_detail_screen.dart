import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final UserModel user;
  final bool editMode;

  const AdminUserDetailScreen({
    super.key,
    required this.user,
    this.editMode = false,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late bool _isEditing;
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessPermitController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;
  late UserRole _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode;
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _businessNameController = TextEditingController(text: widget.user.businessName ?? '');
    _businessPermitController = TextEditingController(text: widget.user.businessPermitNo ?? '');
    _emergencyContactNameController = TextEditingController(text: widget.user.emergencyContactName ?? '');
    _emergencyContactPhoneController = TextEditingController(text: widget.user.emergencyContactPhone ?? '');
    _selectedRole = widget.user.role ?? UserRole.student;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    _businessPermitController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<AdminProvider>().updateUser(widget.user.uid, {
        'display_name': _displayNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text.isEmpty ? null : _phoneController.text,
        'role': _selectedRole.name,
        'first_name': _firstNameController.text.isEmpty ? null : _firstNameController.text,
        'last_name': _lastNameController.text.isEmpty ? null : _lastNameController.text,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
        'business_name': _businessNameController.text.isEmpty ? null : _businessNameController.text,
        'business_permit_no': _businessPermitController.text.isEmpty ? null : _businessPermitController.text,
        'emergency_contact_name': _emergencyContactNameController.text.isEmpty ? null : _emergencyContactNameController.text,
        'emergency_contact_phone': _emergencyContactPhoneController.text.isEmpty ? null : _emergencyContactPhoneController.text,
      });
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${widget.user.displayName}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await context.read<AdminProvider>().deleteUser(widget.user.uid);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = user.displayName.isNotEmpty
        ? user.displayName.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase()
        : 'U';
    final isMobile = MediaQuery.of(context).size.width < 800;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? 'Edit User' : 'User Details',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 24),
        children: [
          _buildProfileHeader(initials, user),
          const SizedBox(height: 32),
          _buildSection('Personal Information', [
            _buildField('Display Name', _displayNameController, enabled: _isEditing),
            _buildField('Email', _emailController, enabled: _isEditing),
            _buildField('Phone Number', _phoneController, enabled: _isEditing, optional: true),
            if (!isMobile) ...[
              _buildField('First Name', _firstNameController, enabled: _isEditing, optional: true),
              _buildField('Last Name', _lastNameController, enabled: _isEditing, optional: true),
            ],
            if (isMobile) ...[
              _buildField('First Name', _firstNameController, enabled: _isEditing, optional: true),
              _buildField('Last Name', _lastNameController, enabled: _isEditing, optional: true),
            ],
            _buildField('Address', _addressController, enabled: _isEditing, optional: true, maxLines: 2),
          ]),
          const SizedBox(height: 24),
          _buildSection('Account', [
            _buildRoleSelector(),
            _buildInfoRow('Created', dateFormat.format(user.createdAt)),
            if (user.lastLoginAt != null) _buildInfoRow('Last Login', dateFormat.format(user.lastLoginAt!)),
            _buildVerificationToggle(),
          ]),
          const SizedBox(height: 24),
          _buildSection('Emergency Contact', [
            _buildField('Contact Name', _emergencyContactNameController, enabled: _isEditing, optional: true),
            _buildField('Contact Phone', _emergencyContactPhoneController, enabled: _isEditing, optional: true),
          ]),
          if (user.role == UserRole.owner) ...[
            const SizedBox(height: 24),
            _buildSection('Business Information', [
              _buildField('Business Name', _businessNameController, enabled: _isEditing, optional: true),
              _buildField('Business Permit No.', _businessPermitController, enabled: _isEditing, optional: true),
            ]),
          ],
          const SizedBox(height: 32),
          if (!_isEditing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteUser,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                label: Text('Delete User', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String initials, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.md],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(initials, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildMiniBadge(user.role),
                    const SizedBox(width: 8),
                    _buildVerificationBadge(user.isVerified),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(UserRole? role) {
    Color color;
    String label;
    switch (role) {
      case UserRole.student:
        color = AppColors.success; label = 'Tenant'; break;
      case UserRole.owner:
        color = AppColors.secondary; label = 'Owner'; break;
      case UserRole.admin:
        color = const Color(0xFF8B5CF6); label = 'Admin'; break;
      default:
        color = AppColors.textMuted; label = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isVerified ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isVerified ? Icons.verified_rounded : Icons.pending_outlined, size: 12, color: isVerified ? AppColors.success : AppColors.warning),
          const SizedBox(width: 4),
          Text(isVerified ? 'Verified' : 'Unverified', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: isVerified ? AppColors.success : AppColors.warning)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border), boxShadow: [AppShadows.md]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool enabled = false, bool optional = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              if (optional) Text(' (optional)', style: GoogleFonts.workSans(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 6),
          enabled
              ? TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  style: GoogleFonts.workSans(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: Text(controller.text.isEmpty ? '—' : controller.text, style: GoogleFonts.workSans(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    if (!_isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Role', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            Text(_selectedRole.name.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedRole = v);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationToggle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Verification Status', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          _isEditing
              ? TextButton(
                  onPressed: () async {
                    try {
                      await context.read<AdminProvider>().toggleVerification(widget.user.uid);
                      if (mounted) setState(() {});
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: Text(widget.user.isVerified ? 'Revoke' : 'Verify', style: TextStyle(fontWeight: FontWeight.bold, color: widget.user.isVerified ? Colors.red : AppColors.primary)),
                )
              : _buildVerificationBadge(widget.user.isVerified),
        ],
      ),
    );
  }
}

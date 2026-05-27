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
    final dateFormat = DateFormat('MMM d, yyyy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_isEditing ? 'Edit User' : 'User Details',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            if (_isEditing)
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary, size: 20),
                onPressed: () => setState(() => _isEditing = true),
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 24),
        _buildProfileHeader(initials, user),
        const SizedBox(height: 24),
        _buildSection('Personal Information', [
          _buildField('Display Name', _displayNameController, enabled: _isEditing),
          _buildField('Email', _emailController, enabled: _isEditing),
          _buildField('Phone Number', _phoneController, enabled: _isEditing, optional: true),
          _buildField('First Name', _firstNameController, enabled: _isEditing, optional: true),
          _buildField('Last Name', _lastNameController, enabled: _isEditing, optional: true),
          _buildField('Address', _addressController, enabled: _isEditing, optional: true, maxLines: 2),
        ]),
        const SizedBox(height: 16),
        _buildSection('Account', [
          _buildRoleSelector(),
          _buildInfoRow('Created', dateFormat.format(user.createdAt)),
          if (user.lastLoginAt != null) _buildInfoRow('Last Login', dateFormat.format(user.lastLoginAt!)),
        ]),
        const SizedBox(height: 16),
        _buildSection('Emergency Contact', [
          _buildField('Contact Name', _emergencyContactNameController, enabled: _isEditing, optional: true),
          _buildField('Contact Phone', _emergencyContactPhoneController, enabled: _isEditing, optional: true),
        ]),
        if (user.role == UserRole.owner) ...[
          const SizedBox(height: 16),
          _buildSection('Business Information', [
            _buildField('Business Name', _businessNameController, enabled: _isEditing, optional: true),
            _buildField('Business Permit No.', _businessPermitController, enabled: _isEditing, optional: true),
          ]),
        ],
        const SizedBox(height: 24),
        if (!_isEditing)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteUser,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
              label: Text('Delete User', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeader(String initials, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.md],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(initials, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                _buildMiniBadge(user.role),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [AppShadows.md]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool enabled = false, bool optional = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              if (optional) Text(' (optional)', style: GoogleFonts.workSans(fontSize: 10, color: AppColors.textMuted.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 4),
          enabled
              ? TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  style: GoogleFonts.workSans(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Text(controller.text.isEmpty ? '—' : controller.text, style: GoogleFonts.workSans(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    if (!_isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Role', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            Text(_selectedRole.name.toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedRole = v);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

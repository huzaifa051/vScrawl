import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class InviteUserScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const InviteUserScreen({super.key, this.onBack});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  int? _selectedRoleId;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _roles = [];
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final json = await AuthService.fetchAvailableRoles();
      _roles = json
          .map((e) => {'roleId': e['roleId'], 'roleName': e['roleName']})
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching roles: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRoles = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.fieldLabel),
    );
  }

  Future<void> _handleInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await AuthService.inviteUser(
        name: _nameController.text.trim(),
        emailAddress: _emailController.text.trim(),
        roleId: _selectedRoleId!,
      );

      if (mounted) {
        (widget.onBack ?? () => Navigator.of(context).pop())();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to invite user: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Invite User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Full Name*'),
                TextFormField(
                  controller: _nameController,
                  decoration: _fieldDecoration(),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Full Name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel('Email Address*'),
                TextFormField(
                  controller: _emailController,
                  decoration: _fieldDecoration(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email Address is required';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _fieldLabel('Roles*'),
                _isLoadingRoles
                    ? const Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<int>(
                        value: _selectedRoleId,
                        decoration: _fieldDecoration(),
                        hint: const Text('--Select--'),
                        items: _roles
                            .map(
                              (role) => DropdownMenuItem<int>(
                                value: role['roleId'] as int,
                                child: Text(role['roleName'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRoleId = value),
                        validator: (value) =>
                            value == null ? 'Please select a role' : null,
                      ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Invite',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

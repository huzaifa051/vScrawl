import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/organization_provider.dart';
import '../services/auth_service.dart';

class OrganizationEditScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OrganizationEditScreen({super.key, required this.onDone});

  @override
  State<OrganizationEditScreen> createState() => _OrganizationEditScreenState();
}

class _OrganizationEditScreenState extends State<OrganizationEditScreen> {
  late final TextEditingController _nameController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final org = context.read<OrganizationProvider>().organization;
    _nameController = TextEditingController(text: org?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final org = context.read<OrganizationProvider>().organization;
    final newName = _nameController.text.trim();

    if (newName.isEmpty || org?.id == null) return;

    setState(() => _isUpdating = true);

    try {
      await AuthService.updateOrganization(
        organizationId: int.parse(org!.id!),
        name: newName,
      );

      if (mounted) {
        await context.read<OrganizationProvider>().fetchOrganization();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Organization Updated')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = context.watch<OrganizationProvider>().organization;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Organization', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Owner', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                enabled: false,
                controller: TextEditingController(text: org?.owner?.name ?? ''),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Email', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                enabled: false,
                controller: TextEditingController(
                  text: org?.owner?.emailAddress,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

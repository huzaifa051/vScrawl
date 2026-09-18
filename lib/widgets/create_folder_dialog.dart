import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_isValid) return;
    setState(() => _isSaving = true);
    try {
      await AuthService.createTemplateFolder(name: _nameController.text.trim());

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create folder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Create Folder',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text(
            'Folder Name',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
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
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (_isValid && !_isSaving) ? _handleSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
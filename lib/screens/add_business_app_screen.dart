import 'package:flutter/material.dart';
import 'package:vscrawl/services/auth_service.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/business_app_provider.dart';

class AddBusinessAppScreen extends StatefulWidget {
  const AddBusinessAppScreen({super.key});

  @override
  State<AddBusinessAppScreen> createState() => _AddBusinessAppScreenState();
}

class _AddBusinessAppScreenState extends State<AddBusinessAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _appNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _callbackUrlController = TextEditingController();

  String _status = 'DISABLED';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _clientIdController.dispose();
    _appNameController.dispose();
    _descriptionController.dispose();
    _callbackUrlController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.fieldLabel),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await AuthService.createBusinessApp(
        clientId: _clientIdController.text.trim(),
        appName: _appNameController.text.trim(),
        description: _descriptionController.text.trim(),
        callbackUrl: _callbackUrlController.text.trim(),
        status: _status == 'ENABLED',
      );

      if (mounted) {
        await context.read<BusinessAppProvider>().fetchBusinessApps();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add app $e')));
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
        title: const Text(
          'Add App',
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
                _fieldLabel('Client ID*'),
                TextFormField(
                  controller: _clientIdController,
                  decoration: _fieldDecoration(),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Client ID is required'
                      : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel('App Name*'),
                TextFormField(
                  controller: _appNameController,
                  decoration: _fieldDecoration(),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'App Name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _fieldDecoration(),
                ),
                const SizedBox(height: 16),

                _fieldLabel('CallBack URL*'),
                TextFormField(
                  controller: _callbackUrlController,
                  decoration: _fieldDecoration(),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Callback URL is required';
                    }
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme) {
                      return 'Enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: RadioGroup<String>(
                    groupValue: _status,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          value: 'DISABLED',
                          activeColor: AppColors.accent,
                          title: const Text('DISABLED'),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          value: 'ENABLED',
                          activeColor: AppColors.accent,
                          title: const Text('ENABLED'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
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
                            'Add',
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

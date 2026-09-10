import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/business_app_provider.dart';
import '../models/business_app_model.dart';

class UpdateBusinessAppScreen extends StatefulWidget {
  final BusinessAppModel app;

  const UpdateBusinessAppScreen({super.key, required this.app});

  @override
  State<UpdateBusinessAppScreen> createState() =>
      _UpdateBusinessAppScreenState();
}

class _UpdateBusinessAppScreenState extends State<UpdateBusinessAppScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _appNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _callbackUrlController;

  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(text: widget.app.appName ?? '');
    _descriptionController = TextEditingController(
      text: widget.app.appName ?? '',
    );
    _callbackUrlController = TextEditingController(
      text: widget.app.callbackUrl ?? '',
    );
    _status = (widget.app.status == 'ENABLED') ? 'ENABLED' : 'DISABLED';
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _descriptionController.dispose();
    _callbackUrlController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({bool enabled = true}) {
    return InputDecoration(
      filled: true,
      fillColor: enabled ? Colors.white : const Color(0xFFF0F0F0),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 6),
      child: Text(text, style: AppTextStyles.fieldLabel),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await AuthService.updateBusinessApp(
        clientId: widget.app.clientId!,
        appName: _appNameController.text.trim(),
        appDescription: _descriptionController.text.trim(),
        callbackUrl: _callbackUrlController.text.trim(),
        status: _status == 'ENABLED',
        webhookActive: widget.app.webhookActive ?? false,
        webhookEvents: widget.app.webhookEvents?.toString() ?? '',
        webhookUrl: widget.app.webhookUrl ?? '',
      );

      if (mounted) {
        await context.read<BusinessAppProvider>().fetchBusinessApps();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update app: $e')));
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
          'Update app',
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
                  enabled: false,
                  controller: TextEditingController(
                    text: widget.app.clientId ?? '',
                  ),
                  decoration: _fieldDecoration(enabled: false),
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
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'DISABLED',
                        groupValue: _status,
                        activeColor: AppColors.accent,
                        title: const Text('DISABLED'),
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'ENABLED',
                        groupValue: _status,
                        activeColor: AppColors.accent,
                        title: const Text("ENABLED"),
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                    ],
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
                            'Update',
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vscrawl/providers/organization_stats_provider.dart';
import 'package:vscrawl/services/auth_service.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/organization_provider.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../providers/business_app_provider.dart';

class OrganizationScreen extends StatefulWidget {
  final VoidCallback onEditOrganization;
  final VoidCallback onViewUsers;
  final VoidCallback onViewBusinessApps;

  const OrganizationScreen({
    super.key,
    required this.onEditOrganization,
    required this.onViewUsers,
    required this.onViewBusinessApps,
  });

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessAppProvider>().fetchBusinessApps();
    });
  }

  Uint8List? _decodeLogo(String? rawLogo) {
    if (rawLogo == null || rawLogo.isEmpty) return null;
    try {
      String base64Part = rawLogo.trim();
      if (base64Part.contains(',')) {
        base64Part = base64Part.split(',').last.trim();
      }
      return base64Decode(base64Part);
    } catch (e) {
      debugPrint('Failed to decode organization logo: $e');
      return null;
    }
  }

  void _handleChangeLogo(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      await AuthService.updateOrganizationLogo(base64Image);
      if (context.mounted) {
        await context.read<OrganizationProvider>().fetchOrganization();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logo updated')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update logo: $e')));
      }
    }
  }

  String _initialsFrom(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1).toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrganizationProvider>(
      builder: (context, orgProvider, _) {
        final org = orgProvider.organization;

        if (orgProvider.isLoading && org == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (org == null) {
          return const Center(child: Text('Unable to load organization'));
        }
        final logoBytes = (org.logo != null && org.logo!.isNotEmpty)
            ? _decodeLogo(org.logo)
            : null;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: logoBytes != null
                                    ? Image.memory(
                                        logoBytes,
                                        width: 188,
                                        height: 175,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 110,
                                        height: 110,
                                        color: const Color(0xFF2D9CDB),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _initialsFrom(org.name ?? ''),
                                          style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _handleChangeLogo(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            org.name ?? '',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: widget.onEditOrganization,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          org.owner?.name ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          org.owner?.emailAddress ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _NavRow(label: 'Templates (15)', onTap: () {}),
                  Consumer<OrganizationStatsProvider>(
                    builder: (context, orgStats, _) {
                      return _NavRow(
                        label: 'Users (${orgStats.usersCount})',
                        onTap: widget.onViewUsers,
                      );
                    },
                  ),
                  Consumer<BusinessAppProvider>(
                    builder: (context, businessAppProvider, _) {
                      return _NavRow(
                        label:
                            'Business Apps (${businessAppProvider.totalElements})',
                        onTap: widget.onViewBusinessApps,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

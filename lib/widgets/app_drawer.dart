import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/pref_service.dart';
import '../providers/user_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final void Function(String? status, String label) onDocumentCategorySelected;

  const AppDrawer({
    super.key,
    required this.onLogout,
    required this.onDocumentCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (userProvider.isLoading && userProvider.user == null) {
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final user = userProvider.user;
                  final name = (user?.name != null && user!.name!.isNotEmpty)
                      ? user.name!
                      : 'User Name';
                  final email = (user?.email != null && user!.email!.isNotEmpty)
                      ? user.email!
                      : 'user@example.com';

                  return Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final imageBytes = userProvider
                              .profileImageBytes;

                          return CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.inputBorder,
                            child: ClipOval(
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: imageBytes != null
                                    ? Image.memory(
                                        imageBytes,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 26,
                                              );
                                            },
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: name,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerSection(
                    title: 'Documents',
                    items: const [
                      _DrawerItemData(
                        Icons.description_outlined,
                        'All Documents',
                        null,
                      ),
                      _DrawerItemData(
                        Icons.insert_drive_file_outlined,
                        'Draft',
                        'DRAFT',
                      ),
                      _DrawerItemData(Icons.access_time, 'Pending', 'PENDING'),
                      _DrawerItemData(Icons.send_outlined, 'Sent', 'SENT'),
                      _DrawerItemData(Icons.edit_outlined, 'Signed', 'SIGNED'),
                      _DrawerItemData(Icons.cancel_outlined, 'Void', 'VOID'),
                      _DrawerItemData(
                        Icons.check_circle_outline,
                        'Completed',
                        'COMPLETED',
                      ),
                    ],

                    onItemTap: (status, label) {
                      Navigator.of(context).pop();
                      onDocumentCategorySelected(status, label);
                    },
                  ),
                  _DrawerSection(
                    title: 'Settings',
                    items: const [
                      _DrawerItemData(Icons.person_outline, 'Account', null),
                      _DrawerItemData(
                        Icons.verified_user_outlined,
                        'Security',
                        null,
                      ),
                      _DrawerItemData(Icons.draw_outlined, 'Signatures', null),
                    ],
                    onItemTap: (staus, label) => Navigator.of(context).pop(),
                  ),
                  _DrawerSection(
                    title: 'Organization',
                    items: const [
                      _DrawerItemData(Icons.groups_outlined, 'Users', null),
                      _DrawerItemData(
                        Icons.dashboard_customize_outlined,
                        'Templates',
                        null,
                      ),
                    ],

                    onItemTap: (status, label) => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Logout',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              onTap: () async {
                await context.read<UserProvider>().clearUser();
                await PrefService.clearLoginSession();
                onLogout();
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _DrawerItemData {
  final IconData icon;
  final String label;
  final String? statusValue;

  const _DrawerItemData(this.icon, this.label, this.statusValue);
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItemData> items;
  final void Function(String? status, String label) onItemTap;

  const _DrawerSection({
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        ...items.map(
          (item) => ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(item.icon, size: 20, color: Colors.black),
            title: Text(
              item.label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            onTap: () => onItemTap(item.statusValue, item.label),
          ),
        ),
      ],
    );
  }
}

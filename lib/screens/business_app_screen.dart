import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vscrawl/services/auth_service.dart';
import '../utils/app_colors.dart';
import '../providers/business_app_provider.dart';
import '../screens/add_business_app_screen.dart';
import '../screens/update_business_app_screen.dart';
import '../widgets/client_secret_dialog.dart';

class BusinessAppScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const BusinessAppScreen({super.key, this.onBack});

  @override
  State<BusinessAppScreen> createState() => _BusinessAppScreenState();
}

class _BusinessAppScreenState extends State<BusinessAppScreen> {
  @override
  void initState() {
    super.initState();
  }

  String _initialsFrom(String name) {
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessAppProvider()..fetchBusinessApps(),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Business App',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddBusinessAppScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: Consumer<BusinessAppProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.apps.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.apps.isEmpty) {
              return const Center(child: Text('No business apps found'));
            }
            return RefreshIndicator(
              onRefresh: () => provider.fetchBusinessApps(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.apps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final app = provider.apps[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Text(
                          _initialsFrom(app.appName ?? ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        app.appName ?? '',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.pageBackground,
                        onSelected: (value) async {
                          if (value == 'update') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateBusinessAppScreen(app: app),
                              ),
                            );
                          } else if (value == 'generate_secret') {
                            try {
                              final secret =
                                  await AuthService.generateBusinessAppSecret(
                                    app.clientId!,
                                  );
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      ClientSecretDialog(secret: secret),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to generate secret $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else if (value == 'remove') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: AppColors.pageBackground,
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Confirm Delete',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Divider(height: 1, thickness: 1),
                                  ],
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this app?',
                                  style: TextStyle(fontSize: 14),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: AppColors.textSecondary,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadiusGeometry.circular(
                                                      8,
                                                    ),
                                              ),
                                            ),
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text(
                                              'No',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.accent,
                                              foregroundColor:
                                                  AppColors.textSecondary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadiusGeometry.circular(
                                                      8,
                                                    ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              'Yes',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              try {
                                await AuthService.deleteBusinessApp(
                                  app.clientId!,
                                );
                                if (context.mounted) {
                                  await context
                                      .read<BusinessAppProvider>()
                                      .fetchBusinessApps();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to remove app $e'),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'update',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Update App'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'generate_secret',
                            child: Row(
                              children: [
                                Icon(Icons.vpn_key_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Generate Secret'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Remove App',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

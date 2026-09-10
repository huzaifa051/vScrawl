import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/business_app_provider.dart';
import '../screens/add_business_app_screen.dart';
import '../screens/update_business_app_screen.dart';

class BusinessAppScreen extends StatefulWidget {
  const BusinessAppScreen({super.key});

  @override
  State<BusinessAppScreen> createState() => _BusinessAppScreenState();
}

class _BusinessAppScreenState extends State<BusinessAppScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessAppProvider>().fetchBusinessApps();
    });
  }

  String _initialsFrom(String name) {
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
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
                      onSelected: (value) {
                        if (value == 'update') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UpdateBusinessAppScreen(app: app),
                            ),
                          );
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
    );
  }
}

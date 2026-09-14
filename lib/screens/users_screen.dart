import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/users_list_provider.dart';
import '../models/users_list_model.dart';

class UsersScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UsersScreen({super.key, this.onBack});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersListProvider>().fetchUsers();
    });
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'JOINED':
        return const Color(0xFF27AE60);
      case 'PENDING':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'JOINED':
        return 'Joined';
      case 'PENDING':
        return 'Pending';
      default:
        return status ?? '';
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
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Users',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Invite',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<UsersListProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchUsers(),
            child: ListView.separated(
              itemBuilder: (context, index) {
                final UserListItemModel user = provider.users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (user.isOwner == true) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.accent,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Owner',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.emailAddress ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _statusColor(user.status)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(user.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(user.status),
                          ),
                        ),
                      ),
                      if (user.isOwner != true)
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: AppColors.pageBackground,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                          onSelected: (value) {},
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit_role',
                              child: Text('Edit Role'),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                'Remove User',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: provider.users.length,
            ),
          );
        },
      ),
    );
  }
}

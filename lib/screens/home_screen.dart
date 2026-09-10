import 'package:flutter/material.dart';
import 'package:vscrawl/providers/user_provider.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends StatelessWidget {
  final void Function(String? status, String label) onCategoryTap;

  const HomeScreen({super.key, required this.onCategoryTap});

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'User';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<UserProvider>().fetchUserProfile(),
              context.read<DashboardProvider>().fetchDashboardData(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final firstName = _getFirstName(userProvider.user?.name);
                    return Text(
                      'Hello $firstName!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                Consumer<DashboardProvider>(
                  builder: (context, dashProvider, _) {
                    final dash = dashProvider.dashboardData;

                    final pending =
                        dash?.pendingDocCount?.toString().padLeft(2, '0') ??
                        '00';
                    final signed =
                        dash?.signedDocCount?.toString().padLeft(2, '0') ??
                        '00';
                    final completed =
                        dash?.completedDocCount?.toString().padLeft(2, '0') ??
                        '00';
                    final draft =
                        dash?.draftDocCount?.toString().padLeft(2, '0') ?? '00';
                    final sent =
                        dash?.sentDocCount?.toString().padLeft(2, '0') ?? '00';
                    final voidCount =
                        dash?.voidDocCount?.toString().padLeft(2, '0') ?? '00';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Sent $sent',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 24,
                                    color: AppColors.inputBorder,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Waiting for you $pending',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              const Text(
                                'Get a document signed',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Send a document to others for e-signing',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 21,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  'Request signature',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    onCategoryTap('PENDING', 'Pending'),
                                child: _StatTile(
                                  value: '00',
                                  label: 'Pending',
                                  color: AppColors.statPending,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onCategoryTap('SIGNED', 'Signed'),
                                child: _StatTile(
                                  value: signed,
                                  label: 'Signed',
                                  color: AppColors.statSigned,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onCategoryTap('SENT', 'Sent'),
                                child: _StatTile(
                                  value: sent,
                                  label: 'Sent',
                                  color: AppColors.statSent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    onCategoryTap('COMPLETED', 'Completed'),
                                child: _StatTile(
                                  value: completed,
                                  label: 'Completed',
                                  color: AppColors.statCompleted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Organizations's Stats",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  value: '00',
                                  label: 'Templates',
                                  color: AppColors.statTemplates,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _StatTile(
                                  value: '00',
                                  label: 'Active Users',
                                  color: AppColors.statActiveUsers,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: 115,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textAlign: TextAlign.center,
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            textAlign: TextAlign.center,
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

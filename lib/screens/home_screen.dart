import 'package:flutter/material.dart';
import 'package:vscrawl/providers/user_provider.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/organization_stats_provider.dart';
import '../screens/business_app_screen.dart';
import '../screens/users_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String? status, String label) onCategoryTap;
  final VoidCallback onNavigateToOrganization;

  const HomeScreen({
    super.key,
    required this.onCategoryTap,
    required this.onNavigateToOrganization,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrganizationStatsProvider()..fetchOrganizationStats(),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<UserProvider>().fetchUserProfile(),
                context.read<DashboardProvider>().fetchDashboardData(),
                context
                    .read<OrganizationStatsProvider>()
                    .fetchOrganizationStats(),
              ]);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final fullName =
                                (userProvider.user?.name != null &&
                                    userProvider.user!.name!.isNotEmpty)
                                ? userProvider.user!.name!
                                : 'User';
                            return Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Hello ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$fullName ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '👋',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        Consumer<DashboardProvider>(
                          builder: (context, dashProvider, _) {
                            final dash = dashProvider.dashboardData;

                            final pending = dash?.pendingDocCount ?? 0;
                            final signed = dash?.signedDocCount ?? 0;
                            final completed = dash?.completedDocCount ?? 0;
                            final draft = dash?.draftDocCount ?? 0;
                            final sent = dash?.sentDocCount ?? 0;
                            final voidCount = dash?.voidDocCount ?? 0;

                            final totalDocuments =
                                pending +
                                signed +
                                sent +
                                completed +
                                voidCount +
                                draft;

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2559),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Get a document signed',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Send a document to others for signing',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.send_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Request Signature'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.accent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                24,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accent,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$totalDocuments',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        const Text(
                                          'documents',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Documents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            _ViewAllButton(
                              onTap: () =>
                                  widget.onCategoryTap(null, 'All Documents'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Consumer<DashboardProvider>(
                          builder: (context, dashProvider, _) {
                            final dash = dashProvider.dashboardData;

                            final pending =
                                dash?.pendingDocCount?.toString() ?? '0';
                            final signed =
                                dash?.signedDocCount?.toString() ?? '0';
                            final sent = dash?.sentDocCount?.toString() ?? '0';
                            final completed =
                                dash?.completedDocCount?.toString() ?? '0';
                            final draft = dash?.draftDocCount?.toString() ?? '0';
                            final voidCount =
                                dash?.voidDocCount?.toString() ?? '0';

                            return GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                              children: [
                                _DocStatCard(
                                  icon: Icons.access_time,
                                  iconColor: const Color(0xFFE07A2C),
                                  iconBg: const Color(0xFFFCEEE0),
                                  value: pending,
                                  label: 'Pending',
                                  onTap: () =>
                                      widget.onCategoryTap('PENDING', 'Pending'),
                                ),
                                _DocStatCard(
                                  icon: Icons.edit_outlined,
                                  iconColor: const Color(0xFF8B5CF6),
                                  iconBg: const Color(0xFFF1EBFB),
                                  value: signed,
                                  label: 'Signed',
                                  onTap: () =>
                                      widget.onCategoryTap('SIGNED', 'Signed'),
                                ),
                                _DocStatCard(
                                  icon: Icons.send_outlined,
                                  iconColor: const Color(0xFF2D9CDB),
                                  iconBg: const Color(0xFFE4F2FA),
                                  value: sent,
                                  label: 'Sent',
                                  onTap: () =>
                                      widget.onCategoryTap('SENT', 'Sent'),
                                ),
                                _DocStatCard(
                                  icon: Icons.check_circle_outline,
                                  iconColor: const Color(0xFF27AE60),
                                  iconBg: const Color(0xFFE4F7EB),
                                  value: completed,
                                  label: 'Completed',
                                  onTap: () => widget.onCategoryTap(
                                    'COMPLETED',
                                    'Completed',
                                  ),
                                ),
                                _DocStatCard(
                                  icon: Icons.article_outlined,
                                  iconColor: const Color(0xFF2F80ED),
                                  iconBg: const Color(0xFFE6EEFB),
                                  value: draft,
                                  label: 'Draft',
                                  onTap: () =>
                                      widget.onCategoryTap('DRAFT', 'Draft'),
                                ),
                                _DocStatCard(
                                  icon: Icons.cancel_outlined,
                                  iconColor: const Color(0xFFEB5757),
                                  iconBg: const Color(0xFFFBE7E7),
                                  value: voidCount,
                                  label: 'Void',
                                  onTap: () =>
                                      widget.onCategoryTap('VOID', 'Void'),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_outlined,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Organization's Stats",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            _ViewAllButton(
                              onTap: widget.onNavigateToOrganization,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Consumer<OrganizationStatsProvider>(
                          builder: (context, orgStats, _) {
                            return GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                              children: [
                                _DocStatCard(
                                  icon: Icons.copy_outlined,
                                  iconColor: const Color(0xFF2D9CDB),
                                  iconBg: const Color(0xFFE4F2FA),
                                  value: '${orgStats.templatesCount}',
                                  label: 'Templates',
                                ),
                                _DocStatCard(
                                  icon: Icons.groups_outlined,
                                  iconColor: const Color(0xFF8B5CF6),
                                  iconBg: const Color(0xFFF1EBFB),
                                  value: '${orgStats.usersCount}',
                                  label: 'Users',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const UsersScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _DocStatCard(
                                  icon: Icons.dashboard_customize_outlined,
                                  iconColor: const Color(0xFFE07A2C),
                                  iconBg: const Color(0xFFFCEEE0),
                                  value: '${orgStats.businessAppsCount}',
                                  label: 'Business Apps',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BusinessAppScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DocStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _DocStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View All',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 14, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

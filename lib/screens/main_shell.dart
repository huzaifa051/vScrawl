import 'package:flutter/material.dart';
import 'package:vscrawl/widgets/scrawl_logo.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import '../services/pref_service.dart';
import '../widgets/app_drawer.dart';
import 'login_screen.dart';
import 'documents_screen.dart';
import 'dart:async';
import '../screens/organization_screen.dart';
import '../screens/organization_edit_screen.dart';
import '../screens/users_screen.dart';
import '../screens/business_app_screen.dart';

enum _OrgView { main, edit, users, businessApps }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  String? _documentStatusFilter;
  String _documentCategoryLabel = 'All Documents';

  _OrgView _orgView = _OrgView.main;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  static const List<String> _titles = [
    'Home',
    'Documents',
    'Organization',
    'Settings',
  ];

  void _openOrganizationEdit() {
    setState(() => _orgView = _OrgView.edit);
  }

  void _openOrganizationUsers() {
    setState(() => _orgView = _OrgView.users);
  }

  void _openOrganizationBusinessApps() {
    setState(() => _orgView = _OrgView.businessApps);
  }

  void _closeOrganizationSubView() {
    setState(() => _orgView = _OrgView.main);
  }

  void _navigateToOrganizationTab() {
    setState(() {
      _selectedIndex = 2;
      _orgView = _OrgView.main;
    });
  }

  Widget _buildOrganizationTab() {
    switch (_orgView) {
      case _OrgView.edit:
        return OrganizationEditScreen(onDone: _closeOrganizationSubView);
      case _OrgView.users:
        return UsersScreen(onBack: _closeOrganizationSubView);
      case _OrgView.businessApps:
        return BusinessAppScreen(onBack: _closeOrganizationSubView);
      case _OrgView.main:
        return OrganizationScreen(
          onEditOrganization: _openOrganizationEdit,
          onViewUsers: _openOrganizationUsers,
          onViewBusinessApps: _openOrganizationBusinessApps,
        );
    }
  }

  List<Widget> get _pages => [
    HomeScreen(
      onCategoryTap: _handleDocumentCategorySelected,
      onNavigateToOrganization: _navigateToOrganizationTab,
    ),
    DocumentsScreen(
      key: ValueKey("${_documentStatusFilter ?? 'all'}_$_searchQuery"),
      statusFilter: _documentStatusFilter,
      emptyStateLabel: _documentCategoryLabel,
      searchQuery: _searchQuery,
    ),
    _buildOrganizationTab(),
    const _PlaceholderTab(label: 'Settings'),
  ];

  Future<void> _handleLogout() async {
    await PrefService.clearLoginSession();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(showLoggedOutMessage: true),
        ),
        (route) => false,
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        _documentStatusFilter = null;
        _documentCategoryLabel = 'All Documents';
      }

      if (index != 1 && _isSearching) {
        _isSearching = false;
        _searchController.clear();
        _searchQuery = '';
      }

      if (index != 2) {
        _orgView = _OrgView.main;
      }
    });
  }

  void _handleDocumentCategorySelected(String? status, String label) {
    setState(() {
      _documentCategoryLabel = label;
      _documentStatusFilter = status;
      _selectedIndex = 1;
    });
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.pageBackground,
      appBar:
          (_selectedIndex == 2 &&
              (_orgView == _OrgView.users || _orgView == _OrgView.businessApps))
          ? null
          : AppBar(
              backgroundColor: AppColors.pageBackground,
              elevation: 0,
              centerTitle: true,
              leading: (_selectedIndex == 2 && _orgView == _OrgView.edit)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _closeOrganizationSubView,
                    )
                  : null,
              title: _selectedIndex == 0
                  ? const ScrawlLogo()
                  : Text(
                      _selectedIndex == 1
                          ? _documentCategoryLabel
                          : _titles[_selectedIndex],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              actions: _selectedIndex == 1
                  ? [
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search),
                        onPressed: _isSearching ? _stopSearch : _startSearch,
                      ),
                    ]
                  : null,
              bottom: (_isSearching && _selectedIndex == 1)
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(64),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: const BorderSide(
                                  color: AppColors.accent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
      drawer: AppDrawer(
        onLogout: _handleLogout,
        onDocumentCategorySelected: _handleDocumentCategorySelected,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: _onTabTapped,
                ),
                _NavItem(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: _onTabTapped,
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.account_balance_outlined,
                  label: 'Organization',
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onTap: _onTabTapped,
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 3,
                  selectedIndex: _selectedIndex,
                  onTap: _onTabTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final Color iconColor = isSelected ? Colors.black : AppColors.textSecondary;

    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 3,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              color: iconColor,
              size: 31,
              weight: isSelected ? 700 : 400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: iconColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;

  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

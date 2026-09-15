import 'package:flutter/material.dart';
import 'package:vscrawl/providers/user_provider.dart';
import 'package:vscrawl/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/organization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  final dashboardProvider = DashboardProvider();
  final organizationProvider = OrganizationProvider();

  await Future.wait([
    userProvider.loadUserFromCache(),
    dashboardProvider.loadDashboardFromCache(),
    organizationProvider.loadOrganizationFromCache(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider..fetchUserProfile()),
        ChangeNotifierProvider.value(
          value: dashboardProvider..fetchDashboardData(),
        ),
        ChangeNotifierProvider.value(
          value: organizationProvider..fetchOrganization(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vScrawl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

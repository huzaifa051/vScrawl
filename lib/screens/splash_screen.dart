import 'package:flutter/material.dart';
import 'package:vscrawl/screens/main_shell.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';
import '../services/pref_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await PrefService.isLoggedIn();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            SizedBox(
              height: 233,
              child: Image.asset(
                'assets/images/splash_scrawl_image.png',
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.description_outlined,
                  size: 140,
                  color: Colors.white24,
                ),
              ),
            ),
            SizedBox(height: 60),
            SizedBox(
              height: 42,
              child: Image.asset('assets/images/splash_scrawl_logo.png'),
            ),
            SizedBox(height: 8),
            const Text('Sign Instantly!', style: AppTextStyles.splashTagLine),
            const Spacer(flex: 3),

            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 6,
                    bottom: 6,
                    right: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.splashBackground,
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.splashBackground,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

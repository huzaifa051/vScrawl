import 'package:flutter/material.dart';
import 'package:vscrawl/providers/dashboard_provider.dart';
import 'package:vscrawl/providers/user_provider.dart';
import '../providers/organization_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/scrawl_logo.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart';
import '../utils/validators.dart';
import 'package:flutter/gestures.dart';
import '../services/auth_service.dart';
import '../widgets/app_banner.dart';
import '../services/pref_service.dart';
import 'main_shell.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final bool showLoggedOutMessage;

  const LoginScreen({super.key, this.showLoggedOutMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  late final TapGestureRecognizer _signUpTapRecognizer;

  bool _isLoading = false;
  bool _rememberMe = true;
  String? _emailError;
  String? _passwordError;
  String? _credentialsError;

  @override
  void initState() {
    super.initState();
    _signUpTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
      };

    if (widget.showLoggedOutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppBanner(
            context,
            message: 'You have been logged out',
            actionLabel: 'Dismiss',
          );
        }
      });
    }
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _passwordError = null;
      _credentialsError = null;
    });

    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    final password = _passwordController.text;
    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.signIn(email: email, password: password);
      debugPrint('Sign in success: $result');

      if (mounted) {
        await PrefService.saveLoginSession(email: email, userData: result);

        if (mounted) {
          await context.read<UserProvider>().fetchUserProfile();
          await context.read<DashboardProvider>().fetchDashboardData();
          await context.read<OrganizationProvider>().fetchOrganization();
        }

        _emailController.clear();
        _passwordController.clear();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainShell()),
          (route) => false,
        );
      }
    } on NetworkException catch (e) {
      if (mounted) {
        showAppBanner(
          context,
          message: e.message,
          actionLabel: 'Retry',
          onAction: _handleSignIn,
        );
      }
    } on InvalidCredentialsException catch (e) {
      setState(() {
        _credentialsError = e.message;
      });
      _formKey.currentState!.validate();
    } catch (e) {
      setState(() {
        _emailError = e.toString().replaceFirst('Exception: ', '');
      });
      _formKey.currentState!.validate();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpTapRecognizer.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const ScrawlLogo(),
                const SizedBox(height: 50),

                SizedBox(
                  height: 220,
                  child: Image.asset(
                    'assets/images/login_scrawl_image.png',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.phone_android,
                      size: 130,
                      color: Colors.black12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sign in', style: AppTextStyles.heading),
                ),
                const SizedBox(height: 20),

                CustomTextFormField(
                  label: 'Email/Username',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: combineValidators([
                    (v) => Validators.required(v, 'Email is required'),
                    Validators.email,
                  ]),
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  label: 'Password',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  isPassword: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignIn(),
                ),
                if (_credentialsError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _credentialsError!,
                    style: AppTextStyles.errorText,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.accent,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 14, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Sign in',
                  onPressed: _handleSignIn,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign up',
                        style: AppTextStyles.linkAccent,
                        recognizer: _signUpTapRecognizer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

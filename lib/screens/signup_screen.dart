import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_form_field.dart';
import 'package:flutter/gestures.dart';
import '../utils/validators.dart';
import '../widgets/scrawl_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/confirmation_bottom_sheet.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late final TapGestureRecognizer _signInTapRecognizer;
  late final TapGestureRecognizer _termsTapRecognizer;

  bool _agreeToTerms = true;

  @override
  void initState() {
    super.initState();
    _signInTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pop();
      };

    _termsTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terms and conditions applied')),
        );
      };
  }

  Future<void> _handleSignUp() async {
    final _isFormValid = _formKey.currentState!.validate();
    if (!_isFormValid) return;

    await showConfirmationBottomSheet(
      context,
      email: _emailController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _signInTapRecognizer.dispose();
    _termsTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Center(child: ScrawlLogo()),
                const SizedBox(height: 28),

                const Text('Sign up', style: AppTextStyles.heading),
                const SizedBox(height: 8),

                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: "Sign in",
                        style: AppTextStyles.linkAccent,
                        recognizer: _signInTapRecognizer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextFormField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.required(v, "Full name is required"),
                ),
                const SizedBox(height: 16),

                CustomTextFormField(
                  label: 'Username',
                  controller: _userNameController,
                  keyboardType: TextInputType.name,
                  focusNode: _usernameFocusNode,
                  textInputAction: TextInputAction.next,
                  validator: combineValidators([
                    (v) => Validators.required(v, 'Username is required'),
                    (v) => Validators.minLength(v, 3),
                  ]),
                ),

                CustomTextFormField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  validator: combineValidators([
                    (v) => Validators.required(v, 'Email is required'),
                    Validators.email,
                  ]),
                ),

                CustomTextFormField(
                  label: 'Password',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  isPassword: true,
                  validator: combineValidators([
                    (v) => Validators.required(v, "Password is required"),
                    (v) => Validators.minLength(v, 6),
                  ]),
                ),
                const SizedBox(height: 16),

                FormField<bool>(
                  initialValue: _agreeToTerms,
                  validator: (value) {
                    if (value != true) {
                      return 'Please agree to the terms and conditions';
                    }
                    return null;
                  },
                  builder: ((field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppColors.accent,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (val) {
                                setState(() => _agreeToTerms = val ?? false);
                                field.didChange(val);
                              },
                            ),
                            const SizedBox(width: 8),

                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: "terms and conditions",
                                      style: AppTextStyles.linkAccent.copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: _termsTapRecognizer,
                                    ),
                                    const TextSpan(text: ' of vScrawl'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (field.hasError)
                          Padding(
                            padding: EdgeInsets.only(left: 4, top: 4),
                            child: Text(
                              field.errorText!,
                              style: AppTextStyles.errorText,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),

                PrimaryButton(label: 'Sign up', onPressed: _handleSignUp),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

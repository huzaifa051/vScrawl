import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

Future<void> showConfirmationBottomSheet(
  BuildContext context, {
  required String email,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ConfirmationBottomSheet(email: email),
  );
}

class ConfirmationBottomSheet extends StatelessWidget {
  final String email;

  const ConfirmationBottomSheet({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/confirmation_shade.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset('assets/images/confirmation_badge.png'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                children: [
                  const Text(
                    'Confirmation mail sent!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight(700),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'A confirmation mail with instructions has been sent to ',
                        ),
                        TextSpan(
                          text: email,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              '. Follow those instructions to confirm your email address and activate your account.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

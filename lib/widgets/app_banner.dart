import 'package:flutter/material.dart';

void showAppBanner(
  BuildContext context, {
  required String message,
  String actionLabel = 'Dismiss',
  VoidCallback? onAction,
  Color backgroundColor = const Color(0xFFF13A3F),
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearMaterialBanners();

  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: backgroundColor,
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            onAction?.call();
          },
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
  );
}

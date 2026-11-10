import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_button.dart';
import 'gawen_text.dart';

class GawenRequestError extends StatelessWidget {
  const GawenRequestError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    margin: const EdgeInsets.only(top: 16),
    decoration: BoxDecoration(
      color: GawenColors.errorSoft,
      border: Border.all(color: const Color(0xFFF5CECE)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: GawenColors.error, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: GawenBodyText(
                message,
                style: const TextStyle(color: Color(0xFFA93636), fontSize: 12),
              ),
            ),
          ],
        ),
        if (onRetry != null)
          Align(
            alignment: Alignment.centerRight,
            child: GawenTextButton(label: retryLabel, onPressed: onRetry),
          ),
      ],
    ),
  );
}

typedef RequestError = GawenRequestError;

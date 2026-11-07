import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RequestError extends StatelessWidget {
  const RequestError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    margin: const EdgeInsets.only(top: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0F0),
      border: Border.all(color: const Color(0xFFF5CECE)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: GawenColors.error, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFA93636),
              height: 1.45,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

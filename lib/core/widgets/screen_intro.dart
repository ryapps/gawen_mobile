import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ScreenIntro extends StatelessWidget {
  const ScreenIntro({
    super.key,
    this.eyebrow,
    required this.title,
    required this.description,
  });

  final String? eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (eyebrow != null) ...[
        Text(
          eyebrow!.toUpperCase(),
          style: const TextStyle(
            color: GawenColors.primary,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
      ],
      Text(
        title,
        style: const TextStyle(
          fontSize: 26,
          height: 1.25,
          letterSpacing: -.7,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        description,
        style: const TextStyle(
          color: GawenColors.muted,
          fontSize: 13,
          height: 1.6,
        ),
      ),
    ],
  );
}

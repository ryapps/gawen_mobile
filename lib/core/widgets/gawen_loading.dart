import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_text.dart';

class GawenLoading extends StatelessWidget {
  const GawenLoading({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
    this.message,
    this.centered = true,
  });

  final double size;
  final double strokeWidth;
  final String? message;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: GawenColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: GawenSpacing.md),
          GawenCaption(message!, textAlign: TextAlign.center),
        ],
      ],
    );
    return centered ? Center(child: loader) : loader;
  }
}

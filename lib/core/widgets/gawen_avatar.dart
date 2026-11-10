import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_image.dart';

class GawenAvatar extends StatelessWidget {
  const GawenAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.assetFallback,
  });

  final String? imageUrl;
  final double size;
  final String? assetFallback;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();
    final fallback = assetFallback;
    if (image == null || image.isEmpty) {
      if (fallback != null) {
        return ClipOval(
          child: Image.asset(
            fallback,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _iconFallback(),
          ),
        );
      }
      return _iconFallback();
    }

    return ClipOval(
      child: GawenImage(
        source: image,
        width: size,
        height: size,
        fit: BoxFit.cover,
        assetFallback: fallback,
      ),
    );
  }

  Widget _iconFallback() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: GawenColors.primarySoft,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.person_outline_rounded,
      size: size * 0.58,
      color: GawenColors.primary,
    ),
  );
}

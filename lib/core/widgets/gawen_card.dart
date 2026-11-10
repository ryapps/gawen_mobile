import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenCard extends StatelessWidget {
  const GawenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GawenSpacing.lg),
    this.margin,
    this.onTap,
    this.backgroundColor = GawenColors.surface,
    this.borderRadius = GawenRadius.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: const BorderSide(color: GawenColors.border),
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: backgroundColor,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

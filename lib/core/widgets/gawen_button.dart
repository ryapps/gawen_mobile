import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenPrimaryButton extends StatelessWidget {
  const GawenPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _GawenButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    enabled: enabled,
    loadingColor: Colors.white,
    builder: (context, onPressed, child) =>
        FilledButton(onPressed: onPressed, child: child),
  );
}

class GawenSecondaryButton extends StatelessWidget {
  const GawenSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _GawenButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    enabled: enabled,
    loadingColor: GawenColors.primary,
    builder: (context, onPressed, child) => FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: GawenColors.primarySoft,
        foregroundColor: GawenColors.primaryDark,
      ),
      child: child,
    ),
  );
}

class GawenOutlinedButton extends StatelessWidget {
  const GawenOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _GawenButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    enabled: enabled,
    loadingColor: GawenColors.primary,
    builder: (context, onPressed, child) =>
        OutlinedButton(onPressed: onPressed, child: child),
  );
}

class GawenTextButton extends StatelessWidget {
  const GawenTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _GawenButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    enabled: enabled,
    loadingColor: GawenColors.primary,
    builder: (context, onPressed, child) =>
        TextButton(onPressed: onPressed, child: child),
  );
}

class GawenDangerButton extends StatelessWidget {
  const GawenDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) => _GawenButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    enabled: enabled,
    loadingColor: Colors.white,
    builder: (context, onPressed, child) => FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: GawenColors.error),
      child: child,
    ),
  );
}

typedef _ButtonBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback? onPressed,
      Widget child,
    );

class _GawenButton extends StatelessWidget {
  const _GawenButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.enabled,
    required this.loadingColor,
    required this.builder,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final Color loadingColor;
  final _ButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: loadingColor,
            ),
          )
        : icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: GawenSpacing.sm),
              Text(label),
            ],
          );
    return builder(context, enabled && !isLoading ? onPressed : null, child);
  }
}

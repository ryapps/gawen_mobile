import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GawenPopupMenuAction<T> {
  const GawenPopupMenuAction({
    required this.value,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool isDestructive;
}

class GawenPopupMenuButton<T> extends StatelessWidget {
  const GawenPopupMenuButton({
    super.key,
    required this.actions,
    required this.onSelected,
    this.child,
    this.label,
    this.triggerIcon = Icons.more_horiz_rounded,
    this.enabled = true,
    this.tooltip = 'Tampilkan pilihan',
  });

  final List<GawenPopupMenuAction<T>> actions;
  final ValueChanged<T> onSelected;
  final Widget? child;
  final String? label;
  final IconData triggerIcon;
  final bool enabled;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final trigger =
        child ??
        (label == null
            ? Icon(triggerIcon, color: GawenColors.primaryDark)
            : Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: GawenColors.surface,
                  border: Border.all(
                    color: GawenColors.primary.withValues(alpha: 0.35),
                  ),
                  borderRadius: BorderRadius.circular(GawenRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(triggerIcon, color: GawenColors.primaryDark),
                    const SizedBox(width: GawenSpacing.sm),
                    Text(
                      label!,
                      style: const TextStyle(
                        color: GawenColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ));
    return PopupMenuButton<T>(
      enabled: enabled && actions.isNotEmpty,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => actions
          .map(
            (action) => PopupMenuItem<T>(
              value: action.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    action.icon,
                    size: 20,
                    color: action.isDestructive
                        ? GawenColors.error
                        : GawenColors.muted,
                  ),
                  const SizedBox(width: GawenSpacing.sm),
                  Text(
                    action.label,
                    style: TextStyle(
                      color: action.isDestructive
                          ? GawenColors.error
                          : GawenColors.text,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
      child: trigger,
    );
  }
}

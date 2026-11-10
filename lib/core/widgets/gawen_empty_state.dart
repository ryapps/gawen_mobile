import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_button.dart';
import 'gawen_card.dart';
import 'gawen_text.dart';

class GawenEmptyState extends StatelessWidget {
  const GawenEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => GawenCard(
    padding: const EdgeInsets.all(GawenSpacing.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 38, color: GawenColors.muted),
        const SizedBox(height: GawenSpacing.md),
        GawenSectionTitle(title, textAlign: TextAlign.center),
        if (description != null) ...[
          const SizedBox(height: GawenSpacing.xs),
          GawenCaption(description!, textAlign: TextAlign.center),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: GawenSpacing.lg),
          GawenOutlinedButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

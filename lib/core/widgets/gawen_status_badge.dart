import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum GawenStatus { pending, active, approved, rejected, inactive }

class GawenStatusBadge extends StatelessWidget {
  const GawenStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.icon,
  });

  final GawenStatus status;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (defaultLabel, foreground, background) = switch (status) {
      GawenStatus.pending => (
        'Menunggu persetujuan',
        const Color(0xFF9A5A08),
        GawenColors.warningSoft,
      ),
      GawenStatus.active => (
        'Aktif',
        GawenColors.primaryDark,
        GawenColors.primarySoft,
      ),
      GawenStatus.approved => (
        'Disetujui',
        GawenColors.primaryDark,
        GawenColors.primarySoft,
      ),
      GawenStatus.rejected => (
        'Ditolak',
        GawenColors.error,
        GawenColors.errorSoft,
      ),
      GawenStatus.inactive => (
        'Nonaktif',
        GawenColors.muted,
        const Color(0xFFF1F2F1),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GawenSpacing.md,
        vertical: GawenSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(GawenRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: GawenSpacing.xs),
          ],
          Text(
            label ?? defaultLabel,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

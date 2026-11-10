import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_text.dart';

class GawenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GawenAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.isLeadingEnabled = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final bool isLeadingEnabled;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GawenSectionTitle(title, style: const TextStyle(fontSize: 18)),
          if (subtitle != null) ...[
            const SizedBox(height: GawenSpacing.xs),
            GawenCaption(subtitle!),
          ],
        ],
      ),
    ),
    leading: isLeadingEnabled
        ? SizedBox(
            width: 70,
            child: Center(
              child: IconButton(
                tooltip: 'Kembali',
                style: IconButton.styleFrom(
                  overlayColor: GawenColors.primarySoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GawenRadius.xl),
                    side: const BorderSide(color: GawenColors.border),
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.chevron_back,
                  color: GawenColors.text,
                ),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            ),
          )
        : null,
    leadingWidth: isLeadingEnabled ? 70 : null,
    centerTitle: false,
    actions: [action ?? const SizedBox(width: 4), const SizedBox(width: 20)],
  );
}

typedef CustomAppBar = GawenAppBar;

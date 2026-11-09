import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.subtitle,
    this.action,
    this.isLeadingEnabled = false,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final bool isLeadingEnabled;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              if (subtitle != null)
              Text(
                subtitle ?? '',
                style: const TextStyle(fontSize: 12, color: GawenColors.muted),
              ),
            ],
          ),
        ),
        leading: isLeadingEnabled
            ? Row(
              children: [
                SizedBox(width: 16),
                IconButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                        GawenColors.primarySoft,
                      ),
                      shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: GawenColors.border),
                  ),
                ),
                          ),
                          icon: const Icon(CupertinoIcons.chevron_back, color: GawenColors.text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
              ],
            )
            : null,
            leadingWidth: isLeadingEnabled ? 70 : null,
        centerTitle: false,
        actions: [action ?? const SizedBox(width: 4), const SizedBox(width: 20)],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

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
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: GawenColors.muted),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [action ?? const SizedBox(width: 4), const SizedBox(width: 4)],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class MoreMenu extends StatelessWidget {
  const MoreMenu({super.key, required this.title, required this.icon, required this.subtitle, required this.onTap});

  final String title;
  final Widget icon;
  final String subtitle;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GawenColors.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GawenColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: title.contains('Keluar') ? GawenColors.error : GawenColors.text)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: title.contains('Keluar') ? GawenColors.error : GawenColors.muted)),
                ],
                ),
            ),
            Icon(CupertinoIcons.chevron_forward, size: 20, color: title.contains('Keluar') ? GawenColors.error : GawenColors.muted),
          ],
        ),
      ),
    );
  }
}
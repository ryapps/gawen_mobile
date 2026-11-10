import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gawen_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.title = '', this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: GawenSpacing.xxl * 2,
    child: Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: GawenColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GawenRadius.md),
            ),
            fixedSize: const Size(GawenSpacing.xxl + 10, GawenSpacing.xxl + 10),
          ),
        ),
        Expanded(child: GawenSectionTitle(title, textAlign: TextAlign.center)),
        const SizedBox(width: GawenSpacing.xxl + 10),
      ],
    ),
  );
}

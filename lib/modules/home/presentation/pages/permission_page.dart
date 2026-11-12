import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_page.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) => GawenPage(
    appBar: GawenAppBar(isLeadingEnabled: true, leadingWidth: 60.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_outline, color: GawenColors.warning, size: 58),
        SizedBox(height: 16),
        Text(
          'Akses terbatas',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text(
          'Backend hanya mengizinkan pemilik usaha melihat dan mengelola daftar karyawan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: GawenColors.muted, height: 1.5),
        ),
      ],
    ),
  );
}

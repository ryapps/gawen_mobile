import 'package:flutter/material.dart';

import '../../domain/entities/employee_entity.dart';
import '../../../../core/theme/app_theme.dart';

class EmployeeStatusBadge extends StatelessWidget {
  const EmployeeStatusBadge({required this.status, super.key});

  final EmployeeEmploymentStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == EmployeeEmploymentStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? GawenColors.primarySoft : const Color(0xFFF1F2F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          fontSize: 12,
          color: active ? GawenColors.primaryDark : GawenColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

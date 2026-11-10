import 'package:flutter/material.dart';

import '../../domain/entities/employee_entity.dart';
import '../../../../core/widgets/gawen_status_badge.dart';

class EmployeeStatusBadge extends StatelessWidget {
  const EmployeeStatusBadge({required this.status, super.key});

  final EmployeeEmploymentStatus status;

  @override
  Widget build(BuildContext context) => GawenStatusBadge(
    status: status == EmployeeEmploymentStatus.active
        ? GawenStatus.active
        : GawenStatus.inactive,
  );
}

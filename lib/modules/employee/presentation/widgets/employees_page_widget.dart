import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_image.dart';
import 'package:frontend/core/widgets/request_error.dart';
import 'package:frontend/modules/employee/domain/entities/employee_entity.dart';
import 'package:frontend/modules/employee/presentation/widgets/employee_status_badge.dart';
import 'package:go_router/go_router.dart';

class StatusFilterChip extends StatelessWidget {
  const StatusFilterChip({
    super.key,
    required this.label,
    this.status,
    required this.filterStatus,
    required this.onFilterChanged,
  });

  final String label;
  final EmployeeEmploymentStatus? status;
  final EmployeeEmploymentStatus? filterStatus;
  final Function(EmployeeEmploymentStatus?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: filterStatus == status,
      showCheckmark: false,
      selectedColor: GawenColors.primary,
      labelStyle: TextStyle(
        color: filterStatus == status ? GawenColors.primarySoft : GawenColors.text,
        fontWeight: filterStatus == status ? FontWeight.w700 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: GawenColors.border),
      ),
      onSelected: (selected) {
        if (selected)
          onFilterChanged(status);
        else
          onFilterChanged(null);
      },
    );
  }
}

class EmployeeListTile extends StatelessWidget {
  const EmployeeListTile({required this.employee});

  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      leading: ClipOval(
        child: GawenImage(
          source: employee.photoProfile,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(employee.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        employee.position?.trim().isNotEmpty == true
            ? employee.position!
            : 'Jabatan belum diatur',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmployeeStatusBadge(status: employee.status),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.push(AppRoutes.employeeDetailPath(employee.id)),
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GawenColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(color: GawenColors.muted)),
  );
}

class RetryMessage extends StatelessWidget {
  const RetryMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RequestError(message: message),
      TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
    ],
  );
}

class EmployeeAccessDenied extends StatelessWidget {
  const EmployeeAccessDenied();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Text(
        'Daftar karyawan hanya dapat diakses oleh pemilik usaha.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class RequestJoinButton extends StatelessWidget {
  const RequestJoinButton({
    super.key,
    required this.onPressed,
    required this.personLength,
    this.loading = false,
    this.failed = false,
  });

  final VoidCallback onPressed;
  final int personLength;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F8F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFD4E8DC)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.person_3,
                  color: GawenColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permintaan bergabung',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loading
                          ? 'Memuat permintaan...'
                          : failed
                          ? 'Tidak dapat memuat. Ketuk untuk mencoba lagi.'
                          : personLength == 0
                          ? 'Belum ada permintaan bergabung'
                          : '$personLength permintaan menunggu ditinjau',
                      style: const TextStyle(
                        fontSize: 11,
                        color: GawenColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (personLength > 0)
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE24B50),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$personLength',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_right,
                color: GawenColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

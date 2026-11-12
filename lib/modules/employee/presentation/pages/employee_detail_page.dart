import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_avatar.dart';
import '../../../../core/widgets/gawen_loading.dart';
import '../../../../core/widgets/gawen_page.dart';
import '../../../../core/widgets/gawen_toast.dart';
import '../../../../core/widgets/request_error.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_bloc.dart';
import '../widgets/employee_status_badge.dart';

class EmployeeDetailPage extends StatefulWidget {
  const EmployeeDetailPage({required this.employeeId, super.key});

  final String employeeId;

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(
      ManagedEmployeeDetailRequested(widget.employeeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthBloc>().state.isOwner) {
      return const _EmployeeAccessDenied();
    }
    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.status == EmployeeStatus.failure) {
          GawenToast.error(context, message: state.message!);
        } else {
          GawenToast.success(context, message: state.message!);
        }
      },
      builder: (context, state) {
        final employee = state.selectedEmployee?.id == widget.employeeId
            ? state.selectedEmployee
            : null;
        final loading = state.detailStatus == EmployeeDetailStatus.loading;
        return GawenPage(
          appBar: GawenAppBar(
            title: 'Detail Karyawan',
            isLeadingEnabled: true,
            leadingWidth: 60.0,
          ),
          padding: EdgeInsets.zero,
          scrollable: false,
          child: loading && employee == null
              ? const GawenLoading()
              : employee == null
              ? _LoadFailure(
                  message: state.detailMessage ?? 'Karyawan tidak ditemukan.',
                  onRetry: _reload,
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GawenSpacing.pageHorizontal,
                    vertical: GawenSpacing.pageVertical,
                  ),
                  children: [
                    Center(
                      child: GawenAvatar(
                        imageUrl: employee.photoProfile,
                        size: 92,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      employee.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: EmployeeStatusBadge(status: employee.status)),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: GawenColors.background,
                        border: Border.all(color: GawenColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: CupertinoIcons.mail,
                            label: 'Email',
                            value: employee.email ?? '-',
                          ),

                          _InfoRow(
                            icon: CupertinoIcons.phone,
                            label: 'Nomor telepon',
                            value: _phone(employee.phone),
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.briefcase,
                            label: 'Jabatan',
                            value: employee.position?.trim().isNotEmpty == true
                                ? employee.position!
                                : 'Belum diatur',
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.check_mark,
                            label: 'Status',
                            value: _statusLabel(employee.status),
                          ),
                          _InfoRow(
                            icon: CupertinoIcons.clock,
                            label: 'Tanggal bergabung',
                            value: _joinedAt(employee.joinedAt),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: () => _editEmployee(employee),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Informasi'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: state.status == EmployeeStatus.mutating
                          ? null
                          : () => _confirmStatusChange(employee),
                      child: state.status == EmployeeStatus.mutating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              employee.status == EmployeeEmploymentStatus.active
                                  ? 'Nonaktifkan Karyawan'
                                  : 'Aktifkan Kembali',
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _phone(String? value) {
    final phone = value?.trim() ?? '';
    return RegExp(r'^\+?[0-9][0-9\s().-]{5,}$').hasMatch(phone)
        ? phone
        : 'Belum diisi';
  }

  String _statusLabel(EmployeeEmploymentStatus status) =>
      status == EmployeeEmploymentStatus.active ? 'Aktif' : 'Nonaktif';

  String _joinedAt(DateTime? value) {
    if (value == null) return '-';
    final date = value.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _reload() => context.read<EmployeeBloc>().add(
    ManagedEmployeeDetailRequested(widget.employeeId),
  );

  Future<void> _editEmployee(EmployeeEntity employee) async {
    await context.push<void>(AppRoutes.employeeEditPath(employee.id));
    if (mounted) _reload();
  }

  Future<void> _confirmStatusChange(EmployeeEntity employee) async {
    final activating = employee.status == EmployeeEmploymentStatus.inactive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activating ? 'Aktifkan kembali?' : 'Nonaktifkan karyawan?'),
        content: Text(
          activating
              ? 'Karyawan ini akan kembali aktif dalam operasional usaha.'
              : 'Karyawan ini tidak akan aktif dalam operasional usaha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(activating ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<EmployeeBloc>().add(
      ManagedEmployeeStatusUpdateRequested(
        employeeId: employee.id,
        status: activating
            ? EmployeeEmploymentStatus.active
            : EmployeeEmploymentStatus.inactive,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(bottom: BorderSide(color: GawenColors.border)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: GawenColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: GawenColors.muted)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GawenRequestError(message: message),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}

class _EmployeeAccessDenied extends StatelessWidget {
  const _EmployeeAccessDenied();

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

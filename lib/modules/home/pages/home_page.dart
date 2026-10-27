import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gawen_widgets.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status &&
        current.status == AuthStatus.unauthenticated,
    listener: (context, state) {
      context.go(AppRoutes.welcome);
      if (state.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      }
    },
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final name = user?['name'] is String ? user!['name'] as String : '';
        final memberships = user?['memberships'] is List
            ? (user!['memberships'] as List)
                  .whereType<Map<String, dynamic>>()
                  .toList(growable: false)
            : const <Map<String, dynamic>>[];
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
              children: [
                const GawenLogo(),
                const SizedBox(height: 34),
                const Text(
                  'Akun terhubung',
                  style: TextStyle(
                    color: GawenColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name.isEmpty ? 'Selamat datang di Gawen' : 'Halo, $name',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _roleLabel(memberships),
                  style: const TextStyle(
                    color: GawenColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informasi akses dan keanggotaan berasal dari akunmu di server.',
                  style: TextStyle(color: GawenColors.muted, height: 1.5),
                ),
                const SizedBox(height: 23),
                if (memberships.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: GawenColors.border),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Belum ada tempat kerja yang terhubung ke akun ini.',
                      style: TextStyle(height: 1.5),
                    ),
                  )
                else
                  ...memberships.map(_membershipCard),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push(AppRoutes.join),
                  child: const Text('Gabung ke Tempat Kerja'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.requests),
                  child: const Text('Lihat Status Permintaan'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.invitation),
                  child: const Text('Terima Undangan'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const LogoutRequested()),
                  child: const Text('Keluar dari akun'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  String _roleLabel(List<Map<String, dynamic>> memberships) {
    if (memberships.isEmpty) return 'Belum terhubung ke organisasi';
    final role = memberships.first['role'];
    return switch (role) {
      'OWNER' => 'Pemilik Usaha',
      'EMPLOYEE' => 'Karyawan',
      _ => 'Keanggotaan terverifikasi',
    };
  }

  Widget _membershipCard(Map<String, dynamic> membership) {
    final organization = membership['organization'];
    final name =
        organization is Map<String, dynamic> && organization['name'] is String
        ? organization['name'] as String
        : 'Tempat kerja';
    final role = membership['role'] == 'OWNER' ? 'Pemilik Usaha' : 'Karyawan';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GawenColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: GawenColors.primarySoft,
            foregroundColor: GawenColors.primary,
            child: Icon(Icons.work_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: GawenColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        (previous.membershipAccess != current.membershipAccess &&
            current.membershipAccess == MembershipAccess.active) ||
        (previous.status != current.status &&
            current.status == AuthStatus.failure),
    listener: (context, state) {
      if (state.membershipAccess == MembershipAccess.active) {
        context.go(AppRoutes.home);
      } else if (state.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      }
    },
    builder: (context, state) {
      final loading = state.status == AuthStatus.loading;
      final request = state.pendingRequest;
      final organization = request?['organization'];
      final organizationName =
          organization is Map<String, dynamic> && organization['name'] is String
          ? organization['name'] as String
          : null;
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(onBack: () => context.go(AppRoutes.join)),
                const Spacer(),
                const Icon(
                  Icons.schedule_rounded,
                  size: 76,
                  color: GawenColors.warning,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Menunggu Persetujuan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Permintaan bergabungmu sedang menunggu persetujuan pemilik usaha. Fitur organisasi belum dapat diakses sampai keanggotaan disetujui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: GawenColors.muted, height: 1.55),
                ),
                if (organizationName != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: GawenColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      organizationName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: loading
                      ? null
                      : () => context.read<AuthBloc>().add(
                          const SessionRestoreRequested(),
                        ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Periksa Status'),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.join),
                  child: const Text('Gunakan kode bisnis lain'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

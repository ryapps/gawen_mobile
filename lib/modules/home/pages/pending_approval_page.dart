import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gawen_widgets.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

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
      final organizationName = state.pendingRequest?.organization?.name;
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

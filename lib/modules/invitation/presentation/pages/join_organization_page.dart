import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:go_router/go_router.dart';

class JoinOrganizationPage extends StatefulWidget {
  const JoinOrganizationPage({super.key});

  @override
  State<JoinOrganizationPage> createState() => _JoinOrganizationPageState();
}

class _JoinOrganizationPageState extends State<JoinOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AuthBloc>().state.hasVerifiedSession) {
        context.read<InvitationBloc>().add(
          const OwnInvitationsRefreshRequested(),
        );
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<InvitationBloc>().add(
      BusinessCodeSubmitted(_codeController.text),
    );
  }

  Future<void> _restoreAfterInvitationAcceptance() async {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state.status == AuthStatus.loading ||
        authBloc.state.status == AuthStatus.restoring) {
      await authBloc.stream.firstWhere(
        (next) =>
            next.status != AuthStatus.loading &&
            next.status != AuthStatus.restoring,
      );
    }
    final loading = authBloc.stream.firstWhere(
      (next) =>
          next.status == AuthStatus.loading ||
          next.status == AuthStatus.restoring,
    );
    authBloc.add(const SessionRestoreRequested());
    await loading;
    final restored = await authBloc.stream.firstWhere(
      (next) =>
          next.status != AuthStatus.loading &&
          next.status != AuthStatus.restoring,
    );
    if (!mounted) return;
    if (restored.status == AuthStatus.authenticated &&
        restored.membershipAccess == MembershipAccess.active) {
      context.go(AppRoutes.home);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored.message ??
              'Undangan diterima, tetapi status keanggotaan belum dapat diverifikasi. Coba periksa kembali.',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InvitationBloc, InvitationState>(
    listenWhen: (previous, current) =>
        (previous.status != current.status &&
            current.status == InvitationStatus.submitted) ||
        (previous.invitationInboxStatus != current.invitationInboxStatus &&
            current.invitationInboxStatus == InvitationInboxStatus.accepted),
    listener: (context, state) {
      if (state.status == InvitationStatus.submitted) {
        context.read<AuthBloc>().add(const SessionRestoreRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message ?? 'Permintaan telah diperiksa.'),
          ),
        );
        context.go(AppRoutes.requests);
      } else {
        unawaited(_restoreAfterInvitationAcceptance());
      }
    },
    builder: (context, state) {
      final loading = state.status == InvitationStatus.loading;
      final authenticated = context.select(
        (AuthBloc bloc) => bloc.state.hasVerifiedSession,
      );
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(),
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: GawenColors.primarySoft,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: GawenColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const ScreenIntro(
                  title: 'Gabung ke Tempat Kerja',
                  description:
                      'Masukkan kode bisnis 8 karakter yang diberikan pemilik usaha.',
                ),
                if (authenticated) ...[
                  _OwnInvitationsSection(
                    state: state,
                    onRefresh: () => context.read<InvitationBloc>().add(
                      const OwnInvitationsRefreshRequested(),
                    ),
                    onAccept: (invitationId) => context
                        .read<InvitationBloc>()
                        .add(EmployeeInvitationAccepted(invitationId)),
                  ),
                  const SizedBox(height: 16),
                ],
                if (!authenticated)
                  GawenRequestError(
                    message:
                        'Masuk ke akun karyawan terlebih dahulu untuk mengajukan permintaan bergabung.',
                  ),
                if (state.status == InvitationStatus.failure &&
                    state.message != null)
                  GawenRequestError(message: state.message!),
                Form(
                  key: _formKey,
                  child: GawenTextField(
                    controller: _codeController,
                    label: 'Kode bisnis',
                    hint: 'CONTOH: KOPI2024',
                    icon: Icons.key_outlined,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    maxLength: 8,
                    validator: (value) {
                      final code = value?.trim() ?? '';
                      if (!RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(code)) {
                        return 'Masukkan kode 8 huruf atau angka.';
                      }
                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Kode biasanya terdiri dari 8 huruf atau angka.',
                    style: TextStyle(color: GawenColors.muted, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GawenPrimaryButton(
                    label: 'Lanjutkan',
                    onPressed: _submit,
                    isLoading: loading,
                    enabled: authenticated,
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _OwnInvitationsSection extends StatelessWidget {
  const _OwnInvitationsSection({
    required this.state,
    required this.onRefresh,
    required this.onAccept,
  });

  final InvitationState state;
  final VoidCallback onRefresh;
  final ValueChanged<String> onAccept;

  @override
  Widget build(BuildContext context) {
    final loading =
        state.invitationInboxStatus == InvitationInboxStatus.loading;
    final accepting =
        state.invitationInboxStatus == InvitationInboxStatus.mutating;
    return GawenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Undangan untukmu',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: loading ? null : onRefresh,
                tooltip: 'Muat ulang undangan',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (loading)
            const GawenLoading(size: 24)
          else if (state.invitationInboxStatus == InvitationInboxStatus.failure)
            GawenRequestError(
              message: state.invitationInboxMessage ?? 'Undangan gagal dimuat.',
              onRetry: onRefresh,
            )
          else if (state.ownInvitations.isEmpty)
            const Text(
              'Belum ada undangan untuk bergabung.',
              style: TextStyle(color: GawenColors.muted),
            )
          else
            ...state.ownInvitations.map(
              (invitation) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GawenColors.background,
                    borderRadius: BorderRadius.circular(GawenRadius.md),
                    border: Border.all(color: GawenColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.organizationName ?? 'Undangan organisasi',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berlaku sampai ${invitation.expiresAt.toLocal()}',
                        style: const TextStyle(
                          color: GawenColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GawenPrimaryButton(
                        label: 'Terima Undangan',
                        onPressed: () => onAccept(invitation.id),
                        isLoading: accepting,
                        enabled: !accepting,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

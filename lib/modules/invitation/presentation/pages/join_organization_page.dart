import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/invitation/domain/entities/invitation_entity.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:frontend/modules/invitation/presentation/widgets/invitation_card.dart';
import 'package:go_router/go_router.dart';

bool _isValidBusinessCode(String value) {
  final code = value.trim();
  return code.length == 8 &&
      code.codeUnits.every(
        (character) =>
            (character >= 48 && character <= 57) ||
            (character >= 65 && character <= 90) ||
            (character >= 97 && character <= 122),
      );
}

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
    GawenToast.error(
      context,
      message:
          restored.message ??
          'Undangan diterima, tetapi status keanggotaan belum dapat diverifikasi. Coba periksa kembali.',
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InvitationBloc, InvitationState>(
    listenWhen: (previous, current) =>
        (previous.status != current.status &&
            (current.status == InvitationStatus.submitted ||
                current.status == InvitationStatus.failure)) ||
        (previous.invitationInboxStatus != current.invitationInboxStatus &&
            current.invitationInboxStatus == InvitationInboxStatus.accepted),
    listener: (context, state) {
      if (state.status == InvitationStatus.submitted) {
        context.read<AuthBloc>().add(const SessionRestoreRequested());
        GawenToast.success(
          context,
          message:
              state.message ??
              'Permintaan bergabung berhasil dikirim ke pemilik usaha.',
        );
        context.go(AppRoutes.requests);
      } else if (state.status == InvitationStatus.failure) {
        GawenToast.error(
          context,
          message: state.message ?? 'Permintaan bergabung gagal dikirim.',
        );
      } else {
        unawaited(_restoreAfterInvitationAcceptance());
      }
    },
    builder: (context, state) {
      final loading = state.status == InvitationStatus.loading;
      final acceptingInvitation =
          state.invitationInboxStatus == InvitationInboxStatus.mutating;
      final hasInvitations = state.ownInvitations.isNotEmpty;
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              GawenSpacing.lg,
              GawenSpacing.lg,
              GawenSpacing.lg,
              GawenSpacing.xxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _JoinOrganizationHero(),
                    if (hasInvitations) ...[
                      const SizedBox(height: GawenSpacing.xl),
                      _OwnInvitationsSection(
                        invitations: state.ownInvitations,
                        acceptingInvitationId: state.acceptingInvitationId,
                        inboxStatus: state.invitationInboxStatus,
                        inboxMessage: state.invitationInboxMessage,
                        onRetry: () => context.read<InvitationBloc>().add(
                          const OwnInvitationsRefreshRequested(),
                        ),
                        onAccept: (invitationId) => context
                            .read<InvitationBloc>()
                            .add(EmployeeInvitationAccepted(invitationId)),
                      ),
                      const SizedBox(height: GawenSpacing.xl),
                      const _AlternativeDivider(),
                    ] else if (state.invitationInboxStatus ==
                        InvitationInboxStatus.failure) ...[
                      const SizedBox(height: GawenSpacing.xl),
                      GawenRequestError(
                        message:
                            state.invitationInboxMessage ??
                            'Undangan gagal dimuat.',
                        onRetry: () => context.read<InvitationBloc>().add(
                          const OwnInvitationsRefreshRequested(),
                        ),
                      ),
                    ],
                    const SizedBox(height: GawenSpacing.xl),
                    const _JoinWithCodeTitle(),
                    Form(
                      key: _formKey,
                      child: GawenTextField(
                        controller: _codeController,
                        label: 'Kode Bergabung',
                        hint: 'Masukkan 8 karakter kode',
                        icon: Icons.key_outlined,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        maxLength: 8,
                        enabled: !loading && !acceptingInvitation,
                        validator: (value) {
                          if (!_isValidBusinessCode(value ?? '')) {
                            return 'Masukkan kode yang terdiri dari 8 huruf atau angka.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: GawenSpacing.lg),
                    GawenPrimaryButton(
                      label: 'Ajukan Bergabung',
                      onPressed: _submit,
                      isLoading: loading,
                      enabled: !acceptingInvitation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _JoinOrganizationHero extends StatelessWidget {
  const _JoinOrganizationHero();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const GawenLogo(),
      const SizedBox(height: GawenSpacing.xl),
      const GawenTitle(
        'Gabung ke Tempat Kerja',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 23),
      ),
      const SizedBox(height: GawenSpacing.sm),
      const GawenBodyText(
        'Masukkan kode dari pemilik usaha atau pilih undangan yang tersedia.',
        style: TextStyle(color: GawenColors.muted),
      ),
    ],
  );
}

class _JoinWithCodeTitle extends StatelessWidget {
  const _JoinWithCodeTitle();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GawenSectionTitle('Gabung dengan Kode'),
      SizedBox(height: GawenSpacing.xs),
      GawenBodyText(
        'Masukkan kode yang diberikan pemilik usaha.',
        style: TextStyle(color: GawenColors.muted),
      ),
    ],
  );
}

class _AlternativeDivider extends StatelessWidget {
  const _AlternativeDivider();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: GawenColors.border)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: GawenSpacing.md),
        child: GawenCaption('atau'),
      ),
      Expanded(child: Divider(color: GawenColors.border)),
    ],
  );
}

class _OwnInvitationsSection extends StatelessWidget {
  const _OwnInvitationsSection({
    required this.invitations,
    required this.acceptingInvitationId,
    required this.inboxStatus,
    required this.inboxMessage,
    required this.onRetry,
    required this.onAccept,
  });

  final List<InvitationEntity> invitations;
  final String? acceptingInvitationId;
  final InvitationInboxStatus inboxStatus;
  final String? inboxMessage;
  final VoidCallback onRetry;
  final ValueChanged<String> onAccept;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const GawenSectionTitle('Undangan untukmu'),
      const SizedBox(height: GawenSpacing.md),
      for (final invitation in invitations)
        InvitationCard(
          invitation: invitation,
          isLoading: acceptingInvitationId == invitation.id,
          isEnabled: acceptingInvitationId == null,
          onAccept: () => onAccept(invitation.id),
        ),
      if (inboxStatus == InvitationInboxStatus.failure) ...[
        const SizedBox(height: GawenSpacing.md),
        GawenRequestError(
          message: inboxMessage ?? 'Undangan gagal diproses.',
          onRetry: onRetry,
        ),
      ],
    ],
  );
}

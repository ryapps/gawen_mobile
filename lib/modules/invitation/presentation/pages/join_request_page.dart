import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/entities/join_request_entity.dart';
import '../bloc/invitation_bloc.dart';
import '../widgets/invitation_card.dart';

class JoinRequestsPage extends StatefulWidget {
  const JoinRequestsPage({super.key});

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<InvitationBloc>().add(const RequestsRefreshRequested());
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
        previous.invitationInboxStatus != current.invitationInboxStatus &&
        current.invitationInboxStatus == InvitationInboxStatus.accepted,
    listener: (context, state) =>
        unawaited(_restoreAfterInvitationAcceptance()),
    builder: (context, state) => Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (state.status == InvitationStatus.loading) {
              await context.read<InvitationBloc>().stream.firstWhere(
                (next) => next.status != InvitationStatus.loading,
              );
              return;
            }
            context.read<InvitationBloc>().add(
              const RequestsRefreshRequested(),
            );
            await context.read<InvitationBloc>().stream.firstWhere(
              (next) => next.status != InvitationStatus.loading,
            );
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            children: [
              GawenAppBar(
                isLeadingEnabled: true,
              ),
              const SizedBox(height: 20),
              const ScreenIntro(
                title: 'Status Permintaan',
                description:
                    'Status terbaru permintaan bergabungmu dari server.',
              ),
              if (state.ownInvitations.isNotEmpty) ...[
                const SizedBox(height: 20),
                const GawenSectionTitle('Undangan untukmu'),
                const SizedBox(height: 12),
                ...state.ownInvitations.map(
                  (invitation) => _invitationCard(invitation, state),
                ),
              ],
              if (state.invitationInboxStatus == InvitationInboxStatus.failure)
                GawenRequestError(
                  message:
                      state.invitationInboxMessage ?? 'Undangan gagal dimuat.',
                  onRetry: () => context.read<InvitationBloc>().add(
                    const RequestsRefreshRequested(),
                  ),
                ),
              if (state.status == InvitationStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: GawenLoading(),
                )
              else if (state.status == InvitationStatus.failure)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GawenRequestError(
                    message: state.message ?? 'Gagal memuat status.',
                    onRetry: () => context.read<InvitationBloc>().add(
                      const RequestsRefreshRequested(),
                    ),
                  ),
                )
              else if (state.requests.isEmpty && state.ownInvitations.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: GawenEmptyState(
                    title: 'Belum ada permintaan bergabung',
                  ),
                )
              else
                ...state.requests.map(_requestCard),
              const SizedBox(height: 20),
              GawenPrimaryButton(
                label: 'Masukkan Kode Bisnis',
                onPressed: () => context.push(AppRoutes.join),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _invitationCard(InvitationEntity invitation, InvitationState state) {
    final accepting = state.acceptingInvitationId == invitation.id;
    return InvitationCard(
      invitation: invitation,
      isLoading: accepting,
      isEnabled: state.acceptingInvitationId == null,
      onAccept: () => context.read<InvitationBloc>().add(
        EmployeeInvitationAccepted(invitation.id),
      ),
    );
  }

  Widget _requestCard(JoinRequestEntity request) {
    final orgName = request.organization?.name ?? 'Tempat kerja';
    return GawenCard(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: GawenColors.primaryDark,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              orgName.isEmpty ? 'G' : orgName.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orgName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                GawenStatusBadge(
                  status: switch (request.status) {
                    JoinRequestStatus.pending => GawenStatus.pending,
                    JoinRequestStatus.approved => GawenStatus.approved,
                    JoinRequestStatus.rejected => GawenStatus.rejected,
                    null => GawenStatus.inactive,
                  },
                  label: request.status == null
                      ? 'Status belum tersedia'
                      : null,
                  icon: switch (request.status) {
                    JoinRequestStatus.pending => Icons.schedule,
                    JoinRequestStatus.approved => Icons.check_circle,
                    JoinRequestStatus.rejected => Icons.cancel_outlined,
                    null => Icons.help_outline,
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

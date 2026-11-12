import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/core/widgets/gawen_avatar.dart';
import 'package:frontend/core/widgets/gawen_card.dart';
import 'package:frontend/core/widgets/gawen_empty_state.dart';
import 'package:frontend/core/widgets/gawen_loading.dart';
import 'package:frontend/core/widgets/gawen_page.dart';
import 'package:frontend/core/widgets/gawen_popup_menu_button.dart';
import 'package:frontend/core/widgets/gawen_status_badge.dart';
import 'package:frontend/core/widgets/gawen_text.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/invitation/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:go_router/go_router.dart';

class OwnerJoinRequestDetailPage extends StatefulWidget {
  const OwnerJoinRequestDetailPage({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  final String requestId;
  final JoinRequestEntity? initialRequest;

  @override
  State<OwnerJoinRequestDetailPage> createState() =>
      _OwnerJoinRequestDetailPageState();
}

class _OwnerJoinRequestDetailPageState
    extends State<OwnerJoinRequestDetailPage> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          final request =
              _findRequest(state.ownerRequests) ?? _validInitialRequest();
          return GawenPage(
            appBar: GawenAppBar(
              title: 'Detail Permintaan',
              isLeadingEnabled: true,
              leadingWidth: 60.0,
            ),
            child: request == null
                ? state.ownerRequestsStatus == OwnerJoinRequestsStatus.loading
                      ? const GawenLoading()
                      : GawenEmptyState(
                          title: 'Detail permintaan tidak tersedia',
                          icon: Icons.person_search_outlined,
                          actionLabel: 'Muat ulang',
                          onAction: _reloadRequests,
                        )
                : _RequestDetails(
                    request: request,
                    busy:
                        state.ownerRequestsStatus ==
                        OwnerJoinRequestsStatus.mutating,
                    onDecision: _decide,
                  ),
          );
        },
      );

  JoinRequestEntity? _findRequest(List<JoinRequestEntity> requests) {
    for (final request in requests) {
      if (request.id == widget.requestId) return request;
    }
    return null;
  }

  JoinRequestEntity? _validInitialRequest() {
    final request = widget.initialRequest;
    return request?.id == widget.requestId ? request : null;
  }

  void _reloadRequests() {
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<InvitationBloc>().add(
        OwnerJoinRequestsRefreshRequested(organizationId),
      );
    }
  }

  Future<void> _decide(bool approve) async {
    final invitationBloc = context.read<InvitationBloc>();
    if (invitationBloc.state.ownerRequestsStatus ==
        OwnerJoinRequestsStatus.mutating) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(approve ? 'Terima permintaan?' : 'Tolak permintaan?'),
        content: Text(
          approve
              ? 'Pemohon akan menjadi anggota aktif organisasi.'
              : 'Permintaan bergabung ini akan ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(approve ? 'Terima' : 'Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId == null) return;
    final completed = invitationBloc.stream.firstWhere(
      (state) =>
          state.ownerRequestsStatus != OwnerJoinRequestsStatus.mutating &&
          state.ownerRequestsMessage != null,
    );
    invitationBloc.add(
      OwnerJoinRequestDecisionRequested(
        organizationId: organizationId,
        requestId: widget.requestId,
        approve: approve,
      ),
    );
    final result = await completed;
    if (!mounted) return;
    final succeeded =
        result.ownerRequestsMessage?.startsWith('Permintaan karyawan') == true;
    if (succeeded) {
      context.pop(true);
    }
  }
}

class _RequestDetails extends StatelessWidget {
  const _RequestDetails({
    required this.request,
    required this.busy,
    required this.onDecision,
  });

  final JoinRequestEntity request;
  final bool busy;
  final ValueChanged<bool> onDecision;

  @override
  Widget build(BuildContext context) {
    final user = request.user;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: GawenSpacing.pageHorizontal,
        vertical: GawenSpacing.pageVertical,
      ),
      children: [
        GawenCard(
          child: Column(
            children: [
              GawenAvatar(imageUrl: user?.photoProfile, size: 92),
              const SizedBox(height: 14),
              GawenTitle(
                user?.name ?? 'Calon karyawan',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const GawenStatusBadge(
                status: GawenStatus.pending,
                icon: CupertinoIcons.clock,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const GawenSectionTitle('Informasi pemohon'),
        const SizedBox(height: 10),
        GawenCard(
          backgroundColor: GawenColors.background,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(
                icon: CupertinoIcons.mail,
                label: 'Email',
                value: user?.email ?? 'Tidak tersedia',
              ),
              _DetailRow(
                icon: CupertinoIcons.phone,
                label: 'Nomor telepon',
                value: user?.phone?.trim().isNotEmpty == true
                    ? user!.phone!
                    : 'Tidak tersedia',
              ),
              _DetailRow(
                icon: CupertinoIcons.clock,
                label: 'Waktu permintaan',
                value: request.createdAt == null
                    ? 'Tidak tersedia'
                    : _formatRequestDate(request.createdAt!),
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GawenPopupMenuButton<bool>(
            enabled: !busy,
            tooltip: 'Pilih tindakan untuk permintaan',
            actions: const [
              GawenPopupMenuAction(
                value: false,
                label: 'Tolak permintaan',
                icon: Icons.close_rounded,
                isDestructive: true,
              ),
              GawenPopupMenuAction(
                value: true,
                label: 'Terima sebagai karyawan',
                icon: Icons.check_rounded,
              ),
            ],
            onSelected: onDecision,
            label: busy ? 'Memproses...' : 'Pilih tindakan',
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(bottom: BorderSide(color: GawenColors.border)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: GawenColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GawenCaption(label),
              const SizedBox(height: 3),
              GawenBodyText(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatRequestDate(DateTime date) {
  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final isToday =
      DateTime.now().toLocal().day == localDate.day &&
      DateTime.now().toLocal().month == localDate.month &&
      DateTime.now().toLocal().year == localDate.year;
  return '${isToday ? 'Hari ini' : '$day/$month/${localDate.year}'}, '
      '${localDate.hour.toString().padLeft(2, '0')}:'
      '${localDate.minute.toString().padLeft(2, '0')}';
}

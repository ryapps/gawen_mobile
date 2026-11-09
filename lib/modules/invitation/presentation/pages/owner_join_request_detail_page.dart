import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_bar.dart';
import 'package:frontend/core/widgets/gawen_image.dart';
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
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Detail Permintaan',
              isLeadingEnabled: true,
            ),
            body: SafeArea(
              child: request == null
                  ? _UnavailableRequest(
                      loading:
                          state.ownerRequestsStatus ==
                          OwnerJoinRequestsStatus.loading,
                      onRetry: _reloadRequests,
                    )
                  : _RequestDetails(
                      request: request,
                      busy:
                          state.ownerRequestsStatus ==
                          OwnerJoinRequestsStatus.mutating,
                      onDecision: _decide,
                    ),
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
    } else if (result.ownerRequestsMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.ownerRequestsMessage!)));
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Column(
          children: [
            ClipOval(
              child: GawenImage(
                source: user?.photoProfile,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? 'Calon karyawan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 14,
                    color: const Color(0xFF9A5A08),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Menunggu persetujuan',
                    style: TextStyle(
                      color: Color(0xFF9A5A08),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Informasi pemohon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: GawenColors.background,
            border: Border.all(color: GawenColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
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
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : () => onDecision(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: GawenColors.muted,
              side: const BorderSide(color: GawenColors.border),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('Tolak permintaan'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: busy ? null : () => onDecision(true),
            style: FilledButton.styleFrom(
              backgroundColor: GawenColors.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.check, size: 20),
            label: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Terima sebagai karyawan'),
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
              Text(
                label,
                style: const TextStyle(color: GawenColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _UnavailableRequest extends StatelessWidget {
  const _UnavailableRequest({required this.loading, required this.onRetry});

  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: loading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_search_outlined,
                  size: 48,
                  color: GawenColors.muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Detail permintaan tidak tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: onRetry, child: const Text('Muat ulang')),
              ],
            ),
    ),
  );
}

String _formatRequestDate(DateTime date) {
  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final isToday = DateTime.now().toLocal().day == localDate.day &&
      DateTime.now().toLocal().month == localDate.month &&
      DateTime.now().toLocal().year == localDate.year;
  return '${isToday ? 'Hari ini' : '$day/$month/${localDate.year}'}, '
      '${localDate.hour.toString().padLeft(2, '0')}:'
      '${localDate.minute.toString().padLeft(2, '0')}';
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/gawen_widgets.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/employee/presentation/bloc/employee_bloc.dart';
import 'package:frontend/modules/invitation/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

class OwnerJoinRequestsPage extends StatefulWidget {
  const OwnerJoinRequestsPage({super.key});

  @override
  State<OwnerJoinRequestsPage> createState() => _OwnerJoinRequestsPageState();
}

class _OwnerJoinRequestsPageState extends State<OwnerJoinRequestsPage> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InvitationBloc, InvitationState>(
    listenWhen: (previous, current) =>
        previous.ownerRequestsMessage != current.ownerRequestsMessage &&
        current.ownerRequestsMessage != null &&
        (current.ownerRequestsStatus != OwnerJoinRequestsStatus.failure ||
            current.ownerRequests.isNotEmpty ||
            previous.ownerRequestsStatus == OwnerJoinRequestsStatus.mutating),
    listener: (context, state) {
      if (state.ownerRequestsStatus == OwnerJoinRequestsStatus.failure) {
        GawenToast.error(context, message: state.ownerRequestsMessage!);
      } else {
        GawenToast.success(context, message: state.ownerRequestsMessage!);
      }
      if (state.ownerRequestsMessage!.startsWith(
        'Permintaan karyawan disetujui',
      )) {
        context.read<EmployeeBloc>().add(const ManagedEmployeesRequested());
      }
    },
    builder: (context, state) => Scaffold(
      appBar: GawenAppBar(
        title: 'Permintaan Bergabung',

        isLeadingEnabled: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Permintaan masuk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _PendingCount(count: state.ownerRequests.length),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Tinjau calon karyawan yang ingin bergabung dengan tim Anda.',
                style: TextStyle(color: GawenColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              if (state.ownerRequestsStatus ==
                      OwnerJoinRequestsStatus.loading &&
                  state.ownerRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: GawenLoading(),
                )
              else ...[
                if (state.ownerRequestsStatus ==
                        OwnerJoinRequestsStatus.failure &&
                    state.ownerRequests.isEmpty)
                  GawenRequestError(
                    message:
                        state.ownerRequestsMessage ??
                        'Permintaan bergabung gagal dimuat.',
                    onRetry: _loadRequests,
                  ),
                if (state.ownerRequests.isEmpty &&
                    state.ownerRequestsStatus !=
                        OwnerJoinRequestsStatus.failure)
                  const GawenEmptyState(title: 'Belum ada permintaan bergabung')
                else
                  ...state.ownerRequests.map(
                    (request) => _JoinRequestCard(
                      request: request,
                      busy:
                          state.ownerRequestsStatus ==
                          OwnerJoinRequestsStatus.mutating,
                      onDecision: (approve) => _decide(request.id, approve),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  void _loadRequests() {
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId != null) {
      context.read<InvitationBloc>().add(
        OwnerJoinRequestsRefreshRequested(organizationId),
      );
    }
  }

  Future<void> _refresh() async {
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId == null) return;
    final invitationBloc = context.read<InvitationBloc>();
    if (invitationBloc.state.ownerRequestsStatus ==
        OwnerJoinRequestsStatus.mutating) {
      await invitationBloc.stream.firstWhere(
        (state) =>
            state.ownerRequestsStatus != OwnerJoinRequestsStatus.mutating,
      );
    }
    invitationBloc.add(OwnerJoinRequestsRefreshRequested(organizationId));
    await invitationBloc.stream.firstWhere(
      (state) =>
          state.ownerRequestsStatus == OwnerJoinRequestsStatus.ready ||
          state.ownerRequestsStatus == OwnerJoinRequestsStatus.failure,
    );
  }

  Future<void> _decide(String requestId, bool approve) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Setujui permintaan?' : 'Tolak permintaan?'),
        content: Text(
          approve
              ? 'Karyawan akan menjadi anggota aktif organisasi.'
              : 'Permintaan bergabung ini akan ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final organizationId = context.read<AuthBloc>().state.organizationId;
    if (organizationId == null) return;
    context.read<InvitationBloc>().add(
      OwnerJoinRequestDecisionRequested(
        organizationId: organizationId,
        requestId: requestId,
        approve: approve,
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GawenColors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A172B1A),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push(
              AppRoutes.ownerJoinRequestDetailPath(request.id),
              extra: request,
            ),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                children: [
                  Row(
                    children: [
                      GawenAvatar(imageUrl: user?.photoProfile, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Karyawan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (user?.email case final email?)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: GawenColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (user?.phone case final phone?)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  phone,
                                  style: const TextStyle(
                                    color: GawenColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: GawenColors.muted,
                      ),
                    ],
                  ),
                  if (request.createdAt != null) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mengajukan ${_formatRequestTime(request.createdAt!)}',
                        style: const TextStyle(
                          color: GawenColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GawenPopupMenuButton<bool>(
              enabled: !busy,
              tooltip: 'Pilih tindakan untuk permintaan',
              actions: const [
                GawenPopupMenuAction(
                  value: false,
                  label: 'Tolak',
                  icon: Icons.close_rounded,
                  isDestructive: true,
                ),
                GawenPopupMenuAction(
                  value: true,
                  label: 'Terima',
                  icon: Icons.check_rounded,
                ),
              ],
              onSelected: onDecision,
              label: busy ? 'Memproses...' : 'Tinjau permintaan',
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCount extends StatelessWidget {
  const _PendingCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3E4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$count menunggu',
      style: const TextStyle(
        color: Color(0xFF9A5A08),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

String _formatRequestTime(DateTime createdAt) {
  final elapsed = DateTime.now().difference(createdAt);
  if (elapsed.isNegative || elapsed.inMinutes < 1) return 'baru saja';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} menit lalu';
  if (elapsed.inHours < 24) return '${elapsed.inHours} jam lalu';
  if (elapsed.inDays == 1) return 'kemarin';
  return '${elapsed.inDays} hari lalu';
}

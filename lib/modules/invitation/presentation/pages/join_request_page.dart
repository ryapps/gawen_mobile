import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../domain/entities/join_request_entity.dart';
import '../bloc/invitation_bloc.dart';

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

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<InvitationBloc, InvitationState>(
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
                  const PageHeader(),
                  const SizedBox(height: 20),
                  const ScreenIntro(
                    title: 'Status Permintaan',
                    description:
                        'Status terbaru permintaan bergabungmu dari server.',
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
                  else if (state.requests.isEmpty)
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../employees/domain/entities/join_request_entity.dart';
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
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.status == InvitationStatus.failure)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          RequestError(
                            message: state.message ?? 'Gagal memuat status.',
                          ),
                          TextButton(
                            onPressed: () => context.read<InvitationBloc>().add(
                              const RequestsRefreshRequested(),
                            ),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (state.requests.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: GawenColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 38,
                            color: GawenColors.muted,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada permintaan bergabung.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.requests.map(_requestCard),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.join),
                    child: const Text('Masukkan Kode Bisnis'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _requestCard(JoinRequestEntity request) {
    final orgName = request.organization?.name ?? 'Tempat kerja';
    final (label, color, icon) = switch (request.status) {
      null => ('Status belum tersedia', GawenColors.muted, Icons.help_outline),
      JoinRequestStatus.pending => (
        'Menunggu persetujuan',
        GawenColors.warning,
        Icons.schedule,
      ),
      JoinRequestStatus.approved => (
        'Disetujui',
        GawenColors.primary,
        Icons.check_circle,
      ),
      JoinRequestStatus.rejected => (
        'Ditolak',
        GawenColors.error,
        Icons.cancel_outlined,
      ),
    };
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GawenColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
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
                Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

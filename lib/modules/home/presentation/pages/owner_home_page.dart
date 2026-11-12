import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gawen_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../organization/presentation/bloc/organization_bloc.dart';
import '../widgets/home_action_card.dart';
import '../../../../core/widgets/main_navigation.dart';
import '../../../invitation/presentation/bloc/invitation_bloc.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String? _loadedOrganizationId;
  String? _loadedRequestsOrganizationId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final organizationId = auth.organizationId;
    if (organizationId != null && organizationId != _loadedOrganizationId) {
      _loadedOrganizationId = organizationId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OrganizationBloc>().add(
            OrganizationLoadRequested(organizationId),
          );
        }
      });
    }
    if (organizationId != null &&
        organizationId != _loadedRequestsOrganizationId) {
      _loadedRequestsOrganizationId = organizationId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<InvitationBloc>().add(
            OwnerJoinRequestsRefreshRequested(organizationId),
          );
        }
      });
    }

    final organizationFromProfile = auth.activeMembership?.organization;
    return GawenPage(
      bottomNavigationBar: MainNavigation(
        isOwner: true,
        currentPath: AppRoutes.home,
      ),
      scrollable: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GawenLogo(),
          const SizedBox(height: 28),
          const Text(
            'DASHBOARD PEMILIK',
            style: TextStyle(
              color: GawenColors.primary,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Halo, ${auth.userName}',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            organizationFromProfile?.name ?? 'Tempat kerja terhubung',
            style: const TextStyle(color: GawenColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 22),
          BlocBuilder<OrganizationBloc, OrganizationState>(
            builder: (context, state) {
              final organization = state.organization;
              final name =
                  organization?.name ??
                  organizationFromProfile?.name ??
                  'Usaha';
              return _OwnerSummary(
                organizationName: name,
                memberCount: organization?.memberCount,
                loading: state.status == OrganizationStatus.loading,
                onRetry: () {
                  if (organizationId != null) {
                    context.read<OrganizationBloc>().add(
                      OrganizationLoadRequested(organizationId),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          BlocBuilder<InvitationBloc, InvitationState>(
            builder: (context, invitationState) => _PendingSummary(
              count: invitationState.ownerRequests.length,
              loading:
                  invitationState.ownerRequestsStatus ==
                  OwnerJoinRequestsStatus.loading,
              failed:
                  invitationState.ownerRequestsStatus ==
                  OwnerJoinRequestsStatus.failure,
              onTap: () => context.go(AppRoutes.inviteEmployee),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Akses cepat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          HomeActionCard(
            icon: Icons.groups_outlined,
            title: 'Karyawan',
            subtitle: 'Kelola anggota tim',
            onTap: () => context.go(AppRoutes.employees),
          ),
          HomeActionCard(
            icon: Icons.storefront_outlined,
            title: 'Informasi usaha',
            subtitle: 'Lihat atau ubah informasi organisasi',
            onTap: () => context.go(AppRoutes.organization),
          ),
        ],
      ),
    );
  }
}

class _OwnerSummary extends StatelessWidget {
  const _OwnerSummary({
    required this.organizationName,
    required this.memberCount,
    required this.loading,
    required this.onRetry,
  });

  final String organizationName;
  final int? memberCount;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GawenColors.primaryDark,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.storefront_outlined, color: Colors.white, size: 28),
        const SizedBox(height: 14),
        Text(
          organizationName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (memberCount != null)
          Text(
            '$memberCount anggota terdaftar',
            style: const TextStyle(color: Colors.white70),
          )
        else if (loading)
          const Text(
            'Memuat ringkasan organisasi…',
            style: TextStyle(color: Colors.white70),
          )
        else
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Muat ulang informasi usaha',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    ),
  );
}

class _PendingSummary extends StatelessWidget {
  const _PendingSummary({
    required this.count,
    required this.loading,
    required this.failed,
    required this.onTap,
  });

  final int count;
  final bool loading;
  final bool failed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFF5E4),
        foregroundColor: GawenColors.warning,
        child: Icon(Icons.pending_actions_outlined),
      ),
      title: const Text('Permintaan bergabung'),
      subtitle: Text(
        loading
            ? 'Memuat status…'
            : failed
            ? 'Status belum dapat dimuat'
            : '$count menunggu persetujuan',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
